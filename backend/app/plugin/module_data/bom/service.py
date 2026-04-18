# -*- coding: utf-8 -*-

import io
import pandas as pd
from fastapi import UploadFile

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_schema import BatchSetAvailable
from app.core.exceptions import CustomException
from app.core.logger import log
from app.utils.excel_util import ExcelUtil

from .crud import DataBomCRUD
from .schema import (
    DataBomCreateSchema,
    DataBomUpdateSchema,
    DataBomOutSchema,
    DataBomQueryParam
)


class DataBomService:
    """
    BOM清单服务层
    """

    # BOM 字段与 Excel 表头的映射关系
    BOM_HEADER_MAPPING = {
        'id': '主键ID',
        'parent_code': '父代号（关联data_project.code）',
        'code': '代号',
        'spec': '名称',
        'count': '数量',
        'material': '材质',
        'unit_mass': '单重',
        'total_mass': '总重',
        'remark': '备注',
        'uuid': 'UUID全局唯一标识',
        'status': '是否启用(0:启用 1:禁用)',
        'description': '备注/描述',
        'created_time': '创建时间',
        'updated_time': '更新时间',
        'created_id': '创建人ID',
        'updated_id': '更新人ID',
    }
    
    @classmethod
    def _to_dict(cls, obj) -> dict:
        """统一模型转字典方法"""
        return DataBomOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def detail_bom_service(cls, auth: AuthSchema, id: int) -> dict:
        """
        详情
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        
        返回:
        - dict - 数据详情
        """
        obj = await DataBomCRUD(auth).get_by_id_bom_crud(id=id)
        if not obj:
            raise CustomException(msg="该数据不存在")
        return cls._to_dict(obj)
    
    @classmethod
    async def list_bom_service(cls, auth: AuthSchema, search: DataBomQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询
        
        参数:
        - auth: AuthSchema - 认证信息
        - search: DataBomQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await DataBomCRUD(auth).list_bom_crud(search=search_dict, order_by=order_by)
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def list_bom_all_with_procure_service(cls, auth: AuthSchema, search: DataBomQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询（包含外购件）
        
        参数:
        - auth: AuthSchema - 认证信息
        - search: DataBomQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else {}
        # 设置包含外购件标志
        search_dict["include_procure"] = True
        obj_list = await DataBomCRUD(auth).list_bom_crud(search=search_dict, order_by=order_by)
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def list_bom_no_procure_service(cls, auth: AuthSchema) -> list[dict]:
        """
        查询不需要采购的BOM清单列表

        参数:
        - auth: AuthSchema - 认证信息

        返回:
        - list[dict] - 数据列表（仅procure为False的记录）
        """
        search_dict = {"procure": False}
        obj_list = await DataBomCRUD(auth).list_bom_crud(search=search_dict, order_by=[{"id": "asc"}])
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def list_bom_by_project_service(cls, auth: AuthSchema, code: str) -> list[dict]:
        """
        按项目代号查询第一层级BOM清单列表（非递归）

        参数:
        - auth: AuthSchema - 认证信息
        - code: str - 项目代号

        返回:
        - list[dict] - 第一层级BOM数据列表
        """
        # 仅查询 parent_code 等于项目代号的记录，不再进行递归
        search_dict = {"parent_code": code}
        obj_list = await DataBomCRUD(auth).list_bom_crud(search=search_dict, order_by=[{"id": "asc"}])
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def list_bom_recursive_service(cls, auth: AuthSchema, code: str, first_code: str | None = None) -> list[dict]:
        """
        按代号递归查询所有后代BOM列表

        参数:
        - auth: AuthSchema - 认证信息
        - code: str - BOM代号
        - first_code: str | None - 根BOM代号

        返回:
        - list[dict] - 递归BOM数据列表
        """
        obj_list = await DataBomCRUD(auth).list_bom_recursive_crud(code=code, first_code=first_code)
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def list_bom_recursive_all_service(cls, auth: AuthSchema, code: str, first_code: str | None = None) -> list[dict]:
        """
        按代号递归查询所有后代BOM列表（包含外购件）

        参数:
        - auth: AuthSchema - 认证信息
        - code: str - BOM代号
        - first_code: str | None - 根BOM代号

        返回:
        - list[dict] - 递归BOM全量数据列表
        """
        obj_list = await DataBomCRUD(auth).list_bom_recursive_crud(code=code, first_code=first_code, include_procure=True)
        return [cls._to_dict(obj) for obj in obj_list]

    @classmethod
    async def page_bom_service(cls, auth: AuthSchema, page_no: int, page_size: int, search: DataBomQueryParam | None = None, order_by: list[dict] | None = None) -> dict:
        """
        分页查询（数据库分页）
        
        参数:
        - auth: AuthSchema - 认证信息
        - page_no: int - 页码
        - page_size: int - 每页数量
        - search: DataBomQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - dict - 分页查询结果
        """
        search_dict = search.__dict__ if search else {}
        order_by_list = order_by or [{'id': 'asc'}]
        offset = (page_no - 1) * page_size
        result = await DataBomCRUD(auth).page_bom_crud(
            offset=offset,
            limit=page_size,
            order_by=order_by_list,
            search=search_dict
        )
        return result
    
    @classmethod
    async def create_bom_service(cls, auth: AuthSchema, data: DataBomCreateSchema) -> dict:
        """
        创建
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: DataBomCreateSchema - 创建数据
        
        返回:
        - dict - 创建结果
        """
        obj = await DataBomCRUD(auth).create_bom_crud(data=data)
        return cls._to_dict(obj)
    
    @classmethod
    async def update_bom_service(cls, auth: AuthSchema, id: int, data: DataBomUpdateSchema) -> dict:
        """
        更新
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        - data: DataBomUpdateSchema - 更新数据
        
        返回:
        - dict - 更新结果
        """
        # 检查数据是否存在
        obj = await DataBomCRUD(auth).get_by_id_bom_crud(id=id)
        if not obj:
            raise CustomException(msg='更新失败，该数据不存在')
        
        obj = await DataBomCRUD(auth).update_bom_crud(id=id, data=data)
        return cls._to_dict(obj)
    
    @classmethod
    async def delete_bom_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        删除
        
        参数:
        - auth: AuthSchema - 认证信息
        - ids: list[int] - 数据ID列表
        
        返回:
        - None
        """
        if not ids:
            raise CustomException(msg='删除失败，删除对象不能为空')
        
        # 优化：一次性查询所有要删除的对象，减少数据库交互
        search_dict = {"id": ("in", ids)}
        obj_list = await DataBomCRUD(auth).list_bom_crud(search=search_dict)
        
        if len(obj_list) != len(ids):
            found_ids = [obj.id for obj in obj_list]
            missing_ids = set(ids) - set(found_ids)
            raise CustomException(msg=f'删除失败，ID为 {list(missing_ids)} 的数据不存在')
            
        await DataBomCRUD(auth).delete_bom_crud(ids=ids)
    
    @classmethod
    async def set_available_bom_service(cls, auth: AuthSchema, data: BatchSetAvailable) -> None:
        """
        批量设置状态
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: BatchSetAvailable - 批量设置状态数据
        
        返回:
        - None
        """
        await DataBomCRUD(auth).set_available_bom_crud(ids=data.ids, status=data.status)
    
    @classmethod
    async def batch_export_bom_service(cls, obj_list: list[dict]) -> bytes:
        """
        批量导出
        
        参数:
        - obj_list: list[dict] - 数据列表
        
        返回:
        - bytes - 导出的Excel文件内容
        """
        # 复制数据并转换状态
        data = obj_list.copy()
        for item in data:
            # 处理状态
            item["status"] = "启用" if item.get("status") == "0" else "停用"
            # 处理创建者
            creator_info = item.get("created_id")
            if isinstance(creator_info, dict):
                item["created_id"] = creator_info.get("name", "未知")
            else:
                item["created_id"] = "未知"

        return ExcelUtil.export_list2excel(list_data=data, mapping_dict=cls.BOM_HEADER_MAPPING)

    @classmethod
    async def batch_import_bom_service(cls, auth: AuthSchema, file: UploadFile, update_support: bool = False) -> str:
        """
        批量导入
        
        参数:
        - auth: AuthSchema - 认证信息
        - file: UploadFile - 上传的Excel文件
        - update_support: bool - 是否支持更新存在数据
        
        返回:
        - str - 导入结果信息
        """
        # 反转映射关系用于导入
        reverse_header_dict = {v: k for k, v in cls.BOM_HEADER_MAPPING.items()}

        try:
            # 读取Excel文件
            contents = await file.read()
            df = pd.read_excel(io.BytesIO(contents))
            await file.close()

            if df.empty:
                raise CustomException(msg="导入文件为空")

            # 检查表头是否完整
            missing_headers = [header for header in reverse_header_dict.keys() if header not in df.columns]
            if missing_headers:
                raise CustomException(msg=f"导入文件缺少必要的列: {', '.join(missing_headers)}")

            # 重命名列名
            df.rename(columns=reverse_header_dict, inplace=True)
            
            error_msgs = []
            success_count = 0
            count = 0
            
            bom_crud = DataBomCRUD(auth)
            for _index, row in df.iterrows():
                count += 1
                try:
                    data = row.to_dict()
                    # 清理 NaN 值
                    data = {k: (None if pd.isna(v) else v) for k, v in data.items()}
                    
                    # 检查是否已存在（如果支持更新）
                    existing_obj = None
                    if update_support and data.get('id'):
                        existing_obj = await bom_crud.get_by_id_bom_crud(id=int(data['id']))

                    if existing_obj:
                        update_schema = DataBomUpdateSchema.model_validate(data)
                        await bom_crud.update_bom_crud(id=existing_obj.id, data=update_schema)
                    else:
                        create_schema = DataBomCreateSchema.model_validate(data)
                        await bom_crud.create_bom_crud(data=create_schema)
                    
                    success_count += 1
                except Exception as e:
                    error_msgs.append(f"第{count}行: {str(e)}")
                    continue

            result = f"成功导入 {success_count} 条数据"
            if error_msgs:
                result += "\n错误信息:\n" + "\n".join(error_msgs)
            return result
            
        except Exception as e:
            log.error(f"批量导入失败: {str(e)}")
            raise CustomException(msg=f"导入失败: {str(e)}")
    
    @classmethod
    async def import_template_download_bom_service(cls) -> bytes:
        """
        下载导入模板
        
        返回:
        - bytes - Excel文件的二进制数据
        """
        header_list = list(cls.BOM_HEADER_MAPPING.values())
        return ExcelUtil.get_excel_template(
            header_list=header_list,
            selector_header_list=[],
            option_list=[]
        )