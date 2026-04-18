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

    from sqlalchemy.ext.asyncio import AsyncSession

    @classmethod
    async def save_data_service(
        cls, 
        auth: AuthSchema, 
        payload: SaveDataSchema
    ) -> SaveDataResponseSchema:
        """
        保存解析后的数据：
        1. 查重逻辑：先检查 BOM 是否存在重复，如有重复则直接返回。
        2. 项目逻辑：存在则跳过，不存在则创建。
        3. BOM 写入：批量创建 BOM 记录。
        """
        result = SaveDataResponseSchema()
        duplicate_logs = []

        project_crud = DataProjectCRUD(auth)
        bom_crud = DataBomCRUD(auth)

        # --- 第一阶段：预检查 BOM 是否存在重复记录 ---
        for item in payload.bom:
            # 处理 NULL code 情况
            code_val = item.code if (item.code and item.code != "") else ("None", None)
            
            query_params = {
                "project_code": item.project_code,
                "first_code": item.first_code,
                "parent_code": item.parent_code,
                "code": code_val
            }
            
            existing_bom = await bom_crud.get(**query_params)
            if existing_bom:
                msg = f"[重复] <span style='color: orange'>BOM记录已存在：{item.code or '空'}</span>"
                duplicate_logs.append(msg)
            else:
                # msg = f"[正常] <span style='color: green'>BOM记录不存在：{item or '空'}</span>"
                # duplicate_logs.append(msg)
                pass

        # 如果发现重复，直接返回错误信息，不再执行后续写入操作
        if duplicate_logs:
            result.duplicate_count = len(duplicate_logs)
            result.duplicate_logs = duplicate_logs
            return result

        # --- 第二阶段：处理项目信息 (data_project) ---
        existing_project = await project_crud.get(code=payload.project.code)

        if not existing_project:
            # 仅在不存在时创建
            await project_crud.create(data=payload.project)
            result.project_added = 1

        # --- 第三阶段：执行 BOM 写入 (data_bom) ---
        for item in payload.bom:
            await bom_crud.create(data=item)
            result.bom_added += 1

        return result


