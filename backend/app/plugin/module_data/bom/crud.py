# -*- coding: utf-8 -*-

from typing import Sequence

from app.core.base_crud import CRUDBase
from app.api.v1.module_system.auth.schema import AuthSchema
from .model import DataBomModel
from .schema import DataBomCreateSchema, DataBomUpdateSchema, DataBomOutSchema


class DataBomCRUD(CRUDBase[DataBomModel, DataBomCreateSchema, DataBomUpdateSchema]):
    """BOM清单数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD数据层
        
        参数:
        - auth (AuthSchema): 认证信息模型
        """
        super().__init__(model=DataBomModel, auth=auth)

    async def get_by_id_bom_crud(self, id: int, preload: list | None = None) -> DataBomModel | None:
        """
        详情
        
        参数:
        - id (int): 对象ID
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - DataBomModel | None: 模型实例或None
        """
        return await self.get(id=id, preload=preload)
    
    async def list_bom_crud(self, search: dict | None = None, order_by: list[dict] | None = None, preload: list | None = None) -> Sequence[DataBomModel]:
        """
        列表查询
        
        参数:
        - search (dict | None): 查询参数
        - order_by (list[dict] | None): 排序参数，未提供时使用模型默认项
        - preload (list | None): 预加载关系，未提供时使用模型默认项
        
        返回:
        - Sequence[DataBomModel]: 模型实例序列
        """
        if search:
            # 提取递归查询标志并从搜索字典中移除
            recursive = search.pop("recursive", False)
            # 如果指定了递归查询
            if recursive:
                parent_code = search.get("parent_code")
                code = search.get("code")
                first_code = search.get("first_code")
                include_procure = search.get("include_procure", False)
                
                # 处理可能存在的元组包装 (例如 ('eq', value))
                if isinstance(parent_code, (list, tuple)): parent_code = parent_code[1]
                if isinstance(code, (list, tuple)): code = code[1]
                if isinstance(first_code, (list, tuple)): first_code = first_code[1]
                
                if parent_code or code:
                    return await self.list_bom_recursive_crud(
                        code=code, 
                        parent_code=parent_code, 
                        first_code=first_code,
                        include_procure=include_procure
                    )
            
        return await self.list(search=search, order_by=order_by, preload=preload)

    async def list_bom_recursive_crud(self, code: str | None = None, first_code: str | None = None, parent_code: str | None = None, include_procure: bool = False) -> Sequence[DataBomModel]:
        """
        递归获取所有后代BOM
        
        参数:
        - code: str | None - 起始BOM代号
        - first_code: str | None - 根BOM代号（可选，用于限定范围）
        - parent_code: str | None - 父级代号（可选，用于从父级开始递归）
        - include_procure: bool - 是否包含外购件，默认为False
        """
        from sqlalchemy import text
        
        # 初始查询条件
        where_clause = ""
        params = {}
        
        if code:
            where_clause = "code = :code"
            params["code"] = code
        elif parent_code:
            where_clause = "parent_code = :parent_code"
            params["parent_code"] = parent_code
        else:
            return []

        if first_code:
            where_clause += " AND first_code = :first_code"
            params["first_code"] = first_code

        # 过滤条件逻辑
        filter_clause = "" if include_procure else " WHERE procure = 0"

        # 使用递归CTE查询所有后代
        # 增加 b.first_code = d.first_code 约束，防止跨项目/跨根节点抓取重复数据
        sql_str = f"""
            WITH RECURSIVE descendants AS (
                SELECT * FROM data_bom WHERE {where_clause}
                UNION
                SELECT b.* FROM data_bom b
                JOIN descendants d ON b.parent_code = d.code AND b.first_code = d.first_code
                {"WHERE b.first_code = :first_code" if first_code else ""}
            )
            SELECT DISTINCT * FROM descendants{filter_clause}
        """
            
        sql = text(sql_str)
        result = await self.auth.db.execute(sql, params)
        # 将结果转换为模型对象列表
        rows = result.fetchall()
        # 获取列名映射
        columns = result.keys()
        return [DataBomModel(**dict(zip(columns, row))) for row in rows]
    
    async def create_bom_crud(self, data: DataBomCreateSchema) -> DataBomModel | None:
        """
        创建
        
        参数:
        - data (DataBomCreateSchema): 创建模型
        
        返回:
        - DataBomModel | None: 模型实例或None
        """
        return await self.create(data=data)
    
    async def update_bom_crud(self, id: int, data: DataBomUpdateSchema) -> DataBomModel | None:
        """
        更新
        
        参数:
        - id (int): 对象ID
        - data (DataBomUpdateSchema): 更新模型
        
        返回:
        - DataBomModel | None: 模型实例或None
        """
        return await self.update(id=id, data=data)
    
    async def delete_bom_crud(self, ids: list[int]) -> None:
        """
        批量删除
        
        参数:
        - ids (list[int]): 对象ID列表
        
        返回:
        - None
        """
        return await self.delete(ids=ids)
    
    async def set_available_bom_crud(self, ids: list[int], status: str) -> None:
        """
        批量设置可用状态
        
        参数:
        - ids (list[int]): 对象ID列表
        - status (str): 可用状态
        
        返回:
        - None
        """
        return await self.set(ids=ids, status=status)
    
    async def page_bom_crud(self, offset: int, limit: int, order_by: list[dict] | None = None, search: dict | None = None, preload: list | None = None) -> dict:
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
        return await self.page(
            offset=offset,
            limit=limit,
            order_by=order_by_list,
            search=search_dict,
            out_schema=DataBomOutSchema,
            preload=preload
        )