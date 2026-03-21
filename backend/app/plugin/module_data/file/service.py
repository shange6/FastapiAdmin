import os
from datetime import datetime
from pathlib import Path
from fastapi import UploadFile

from app.config.setting import settings
from app.core.exceptions import CustomException
from app.core.logger import log
from app.core.database import async_db_session
from sqlalchemy import select

from app.api.v1.module_system.auth.schema import AuthSchema
from app.plugin.module_data.project.crud import DataProjectCRUD
from app.plugin.module_data.bom.crud import DataBomCRUD
from .schema import UploadResponseSchema, SaveDataSchema, SaveDataResponseSchema
from .WTBOMS import WTBOMS
from .dwg2dxf2list import dwg2dxf, Dxf2List


class DataFileService:
    MAX_UPLOAD_SIZE = 100 * 1024 * 1024  # 100MB

    @classmethod
    async def upload_file_service(
        cls,
        file: UploadFile,
        target_path: str | None = None,
        base_url: str | None = None,
    ) -> UploadResponseSchema:
        if not file or not file.filename:
            raise CustomException(msg="请选择要上传的文件")

        if file.size > cls.MAX_UPLOAD_SIZE:
            raise CustomException(msg="文件大小超过限制")

        try:
            content = await file.read()
            save_dir = settings.STATIC_DIR
            if target_path:
                potential_path = os.path.join(save_dir, target_path.strip("/"))
                if os.path.abspath(potential_path).startswith(os.path.abspath(save_dir)):
                     save_dir = potential_path

            os.makedirs(save_dir, exist_ok=True)

            file_name = "upload_" + os.path.splitext(file.filename)[1]
            file_path = os.path.join(save_dir, file_name)

            Path(file_path).write_bytes(content)

            wtboms = WTBOMS(Dxf2List(dwg2dxf(file_path)))
            return UploadResponseSchema(
                boms=wtboms.boms,
                log=wtboms.log,
                project_code=wtboms.project_code,
                project_name=wtboms.project_name,
                project_no=wtboms.project_no,
                first_code=wtboms.first_code,
                file_count=wtboms.file_count,
            )

        except Exception as e:
            log.error(f"文件上传失败: {e!s}")
            raise CustomException(msg=f"文件上传失败: {e!s}")


    @classmethod
    async def save_data_service(cls, auth: AuthSchema, payload: SaveDataSchema) -> SaveDataResponseSchema:
        """
        保存解析后的数据：项目信息和BOM清单
        """
        result = SaveDataResponseSchema()
        duplicate_logs = []

        # 1. 处理BOM清单：先检查是否存在重复记录
        bom_crud = DataBomCRUD(auth)
        for item in payload.bom:
            # 检查数据库中是否存在相同 first_code, parent_code, code 的记录
            # 使用 CRUDBase 支持的格式处理可能为 None 或空字符串的 code (数据库中存储为 NULL)
            code_val = item.code if (item.code is not None and item.code != "") else ("None", None)
            query_params = {
                "first_code": item.first_code,
                "parent_code": item.parent_code,
                "code": code_val
            }
            existing = await bom_crud.get(**query_params)
            if existing:
                msg = f"[重复] <span style='color: orange'>BOM记录已存在：{item.code or '空'}（根代号：{item.first_code}，父代号：{item.parent_code}）</span>"
                duplicate_logs.append(msg)

        if duplicate_logs:
            result.duplicate_count = len(duplicate_logs)
            result.duplicate_logs = duplicate_logs
            return result

        # 2. 如果全都不重复，则添加BOM记录
        for item in payload.bom:
            await bom_crud.create(data=item)
            result.bom_added += 1

        # 3. 处理项目信息
        project_crud = DataProjectCRUD(auth)
        project = await project_crud.get(code=payload.project.code)

        if not project:
            await project_crud.create(data=payload.project)
            result.project_added = 1

        return result
