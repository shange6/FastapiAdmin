# -*- coding: utf-8 -*-

from typing import Sequence

from app.core.base_crud import CRUDBase
from app.api.v1.module_system.auth.schema import AuthSchema
from .model import DataProjectModel
from .schema import DataProjectCreateSchema, DataProjectUpdateSchema, DataProjectOutSchema


from sqlalchemy import or_, select, func

class DataProjectCRUD(CRUDBase[DataProjectModel, DataProjectCreateSchema, DataProjectUpdateSchema]):
    """项目信息数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD数据层
        
        参数:
        - auth (AuthSchema): 认证信息模型
        """
        super().__init__(model=DataProjectModel, auth=auth)

    async def get_by_id_project_crud(self, id: int, preload: list | None = None) -> DataProjectModel | None:
        """
        详情
        
        参数:
        - id (int): 对象ID
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - DataProjectModel | None: 模型实例或None
        """
        return await self.get(id=id, preload=preload)
    
    async def list_project_crud(self, search: dict | None = None, order_by: list[dict] | None = None, preload: list | None = None) -> Sequence[DataProjectModel]:
        """
        列表查询
        
        参数:
        - search (dict | None): 查询参数
        - order_by (list[dict] | None): 排序参数，未提供时使用模型默认项
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - Sequence[DataProjectModel]: 模型实例序列
        """
        return await self.list(search=search, order_by=order_by, preload=preload)
    
    async def create_project_crud(self, data: DataProjectCreateSchema) -> DataProjectModel | None:
        """
        创建
        
        参数:
        - data (DataProjectCreateSchema): 创建模型
        
        返回:
        - DataProjectModel | None: 模型实例或None
        """
        return await self.create(data=data)
    
    async def update_project_crud(self, id: int, data: DataProjectUpdateSchema) -> DataProjectModel | None:
        """
        更新
        
        参数:
        - id (int): 对象ID
        - data (DataProjectUpdateSchema): 更新模型
        
        返回:
        - DataProjectModel | None: 模型实例或None
        """
        return await self.update(id=id, data=data)
    
    async def delete_project_crud(self, ids: list[int]) -> None:
        """
        批量删除
        
        参数:
        - ids (list[int]): 对象ID列表
        
        返回:
        - None
        """
        return await self.delete(ids=ids)
    
    async def set_available_project_crud(self, ids: list[int], status: str) -> None:
        """
        批量设置可用状态
        
        参数:
        - ids (list[int]): 对象ID列表
        - status (str): 可用状态
        
        返回:
        - None
        """
        return await self.set(ids=ids, status=status)
    
    async def page_project_crud(self, offset: int, limit: int, order_by: list[dict] | None = None, search: dict | None = None, preload: list | None = None) -> dict:
        """
        分页查询
        
        参数:
        - offset (int): 偏移量
        - limit (int): 每页数量
        - order_by (list[dict] | None): 排序参数，未提供时使用模型默认项
        - search (dict | None): 查询参数，未提供时查询所有
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - Dict: 分页数据
        """
        order_by_list = order_by or [{'id': 'asc'}]
        search_dict = search or {}
        
        # 处理关键字搜索（OR 匹配名称、代号、编号）
        keyword = search_dict.pop("keyword", None)
        if keyword:
            keyword_filter = or_(
                DataProjectModel.name.like(f"%{keyword}%"),
                DataProjectModel.code.like(f"%{keyword}%"),
                DataProjectModel.no.like(f"%{keyword}%")
            )
            # 自定义分页查询以应用 OR 条件
            sql = select(self.model).where(keyword_filter)
            # 应用其他普通查询条件（如果有的话）
            conditions = await self._CRUDBase__build_conditions(**search_dict)
            if conditions:
                sql = sql.where(*conditions)
            
            # 分页、排序、预加载等
            sql = sql.order_by(*self._CRUDBase__order_by(order_by_list)).offset(offset).limit(limit)
            for opt in self._CRUDBase__loader_options(preload):
                sql = sql.options(opt)
            
            # 权限过滤
            sql = await self._CRUDBase__filter_permissions(sql)
            
            # 计算总数
            count_sql = select(func.count(DataProjectModel.id)).where(keyword_filter)
            if conditions:
                count_sql = count_sql.where(*conditions)
            count_sql = await self._CRUDBase__filter_permissions(count_sql)
            
            total_result = await self.auth.db.execute(count_sql)
            total = total_result.scalar() or 0
            
            # 执行查询
            result = await self.auth.db.execute(sql)
            items = result.scalars().all()
            
            return {
                "items": [DataProjectOutSchema.model_validate(item).model_dump() for item in items],
                "total": total,
                "page_no": (offset // limit) + 1,
                "page_size": limit
            }
            
        return await self.page(
            offset=offset,
            limit=limit,
            order_by=order_by_list,
            search=search_dict,
            out_schema=DataProjectOutSchema,
            preload=preload
        )