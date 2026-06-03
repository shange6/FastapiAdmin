# -*- coding: utf-8 -*-

from typing import Sequence

from app.core.base_crud import CRUDBase
from app.api.v1.module_system.auth.schema import AuthSchema
from .model import ProduceMakeModel, ProduceMakeFlowModel
from .schema import ProduceMakeCreateSchema, ProduceMakeUpdateSchema, ProduceMakeOutSchema, ProduceMakeFlowCreateSchema


class ProduceMakeCRUD(CRUDBase[ProduceMakeModel, ProduceMakeCreateSchema, ProduceMakeUpdateSchema]):
    """制造流程主数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD数据层
        
        参数:
        - auth (AuthSchema): 认证信息模型
        """
        super().__init__(model=ProduceMakeModel, auth=auth)

    async def get_by_id_blanking_crud(self, id: int, preload: list | None = None) -> ProduceMakeModel | None:
        """
        详情
        
        参数:
        - id (int): 对象ID
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - ProduceMakeModel | None: 模型实例或None
        """
        return await self.get(id=id, preload=preload)
    
    async def list_blanking_crud(self, search: dict | None = None, order_by: list[dict] | None = None, preload: list | None = None) -> Sequence[ProduceMakeModel]:
        """
        列表查询
        
        参数:
        - search (dict | None): 查询参数
        - order_by (list[dict] | None): 排序参数，未提供时使用模型默认项
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - Sequence[ProduceMakeModel]: 模型实例序列
        """
        from sqlalchemy import select, and_, or_, collate
        from app.plugin.module_produce.order.model import ProduceOrderModel
        from app.plugin.module_produce.craft.model import ProduceCraftModel
        
        plan_user = None
        search_dict = {}
        if search:
            search_dict = dict(search)
            plan_user = search_dict.pop("plan_user", None)
            
        if not plan_user:
            return await self.list(search=search_dict, order_by=order_by, preload=preload)
            
        try:
            conditions = await self._CRUDBase__build_conditions(**search_dict) if search_dict else []
            sql = select(self.model).where(*conditions)
            sql = sql.join(
                ProduceOrderModel,
                collate(ProduceOrderModel.no, 'utf8mb4_general_ci') == collate(self.model.order_no, 'utf8mb4_general_ci')
            ).join(
                ProduceCraftModel,
                ProduceCraftModel.id == ProduceOrderModel.craft_id
            ).where(
                or_(
                    ProduceOrderModel.craft_id == self.model.current_craft_id,
                    ProduceCraftModel.parent_id == self.model.current_craft_id
                )
            ).where(ProduceOrderModel.plan_user == plan_user)
            
            order = order_by or [{"id": "asc"}]
            sql = sql.order_by(*self._CRUDBase__order_by(order))
            for opt in self._CRUDBase__loader_options(preload):
                sql = sql.options(opt)
            sql = await self._CRUDBase__filter_permissions(sql)
            
            result = await self.auth.db.execute(sql)
            return result.scalars().all()
        except Exception as e:
            from app.core.exceptions import CustomException
            raise CustomException(msg=f"列表查询失败: {e!s}")
    
    async def create_blanking_crud(self, data: ProduceMakeCreateSchema) -> ProduceMakeModel | None:
        """
        创建
        
        参数:
        - data (ProduceMakeCreateSchema): 创建模型
        
        返回:
        - ProduceMakeModel | None: 模型实例或None
        """
        return await self.create(data=data)
    
    async def update_blanking_crud(self, id: int, data: ProduceMakeUpdateSchema) -> ProduceMakeModel | None:
        """
        更新
        
        参数:
        - id (int): 对象ID
        - data (ProduceMakeUpdateSchema): 更新模型
        
        返回:
        - ProduceMakeModel | None: 模型实例或None
        """
        return await self.update(id=id, data=data)
    
    async def delete_blanking_crud(self, ids: list[int]) -> None:
        """
        批量删除
        
        参数:
        - ids (list[int]): 对象ID列表
        
        返回:
        - None
        """
        return await self.delete(ids=ids)
    
    async def set_available_blanking_crud(self, ids: list[int], status: str) -> None:
        """
        批量设置可用状态
        
        参数:
        - ids (list[int]): 对象ID列表
        - status (str): 可用状态
        
        返回:
        - None
        """
        return await self.set(ids=ids, status=status)
    
    async def page_blanking_crud(self, offset: int, limit: int, order_by: list[dict] | None = None, search: dict | None = None, preload: list | None = None) -> dict:
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
        from sqlalchemy import select, and_, or_, func, collate
        from sqlalchemy.inspection import inspect as sa_inspect
        from app.plugin.module_produce.order.model import ProduceOrderModel
        from app.plugin.module_produce.craft.model import ProduceCraftModel
        from app.core.exceptions import CustomException
        
        plan_user = None
        search_dict = {}
        if search:
            search_dict = dict(search)
            plan_user = search_dict.pop("plan_user", None)
            
        if not plan_user:
            order_by_list = order_by or [{'id': 'asc'}]
            return await self.page(
                offset=offset,
                limit=limit,
                order_by=order_by_list,
                search=search_dict,
                out_schema=ProduceMakeOutSchema,
                preload=preload
            )
            
        try:
            conditions = await self._CRUDBase__build_conditions(**search_dict) if search_dict else []
            
            # Base query
            sql = select(self.model).where(*conditions)
            sql = sql.join(
                ProduceOrderModel,
                collate(ProduceOrderModel.no, 'utf8mb4_general_ci') == collate(self.model.order_no, 'utf8mb4_general_ci')
            ).join(
                ProduceCraftModel,
                ProduceCraftModel.id == ProduceOrderModel.craft_id
            ).where(
                or_(
                    ProduceOrderModel.craft_id == self.model.current_craft_id,
                    ProduceCraftModel.parent_id == self.model.current_craft_id
                )
            ).where(ProduceOrderModel.plan_user == plan_user)
            
            # Count query
            mapper = sa_inspect(self.model)
            pk_cols = list(getattr(mapper, "primary_key", []))
            if pk_cols:
                count_sql = select(func.count(pk_cols[0])).select_from(self.model)
            else:
                count_sql = select(func.count()).select_from(self.model)
            
            count_sql = count_sql.join(
                ProduceOrderModel,
                collate(ProduceOrderModel.no, 'utf8mb4_general_ci') == collate(self.model.order_no, 'utf8mb4_general_ci')
            ).join(
                ProduceCraftModel,
                ProduceCraftModel.id == ProduceOrderModel.craft_id
            ).where(*conditions).where(
                or_(
                    ProduceOrderModel.craft_id == self.model.current_craft_id,
                    ProduceCraftModel.parent_id == self.model.current_craft_id
                )
            ).where(ProduceOrderModel.plan_user == plan_user)
            
            # Filter permissions
            sql = await self._CRUDBase__filter_permissions(sql)
            count_sql = await self._CRUDBase__filter_permissions(count_sql)
            
            # Execute count
            count_result = await self.auth.db.execute(count_sql)
            total = count_result.scalar() or 0
            
            # Sorting, pagination, preloads
            order = order_by or [{"id": "asc"}]
            sql = sql.order_by(*self._CRUDBase__order_by(order)).offset(offset).limit(limit)
            for opt in self._CRUDBase__loader_options(preload):
                sql = sql.options(opt)
                
            # Execute data
            result = await self.auth.db.execute(sql)
            obj_list = result.scalars().all()
            
            # Format items
            items = [ProduceMakeOutSchema.model_validate(obj).model_dump() for obj in obj_list]
            return {
                "items": items,
                "total": total
            }
        except Exception as e:
            raise CustomException(msg=f"分页查询失败: {e!s}")


class ProduceMakeFlowCRUD(CRUDBase[ProduceMakeFlowModel, ProduceMakeFlowCreateSchema, ProduceMakeFlowCreateSchema]):
    """制造流程执行数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD数据层
        
        参数:
        - auth (AuthSchema): 认证信息模型
        """
        super().__init__(model=ProduceMakeFlowModel, auth=auth)

    async def create_flow_crud(self, data: ProduceMakeFlowCreateSchema) -> ProduceMakeFlowModel | None:
        """
        创建执行记录
        
        参数:
        - data (ProduceMakeFlowCreateSchema): 创建模型
        
        返回:
        - ProduceMakeFlowModel | None: 模型实例或None
        """
        return await self.create(data=data)