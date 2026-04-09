# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class ProduceBomManhourCreateSchema(BaseModel):
    """
    BOM工时关联新增模型
    """
    bom_id: int = Field(default=..., description='BOM ID')
    craft_id: int = Field(default=..., description='工序ID')
    manhour: int = Field(default=..., description='工时')


class ProduceBomManhourUpdateSchema(ProduceBomManhourCreateSchema):
    """
    BOM工时关联更新模型
    """
    ...


class ProduceBomManhourOutSchema(ProduceBomManhourCreateSchema, BaseSchema, UserBySchema):
    """
    BOM工时关联响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceBomManhourUpsertItemSchema(BaseModel):
    bom_id: int = Field(default=..., description="BOM ID")
    craft_id: int = Field(default=..., description="工序ID")
    manhour: int = Field(default=..., description="工时")


class ProduceBomManhourUpsertBatchSchema(BaseModel):
    items: list[ProduceBomManhourUpsertItemSchema] = Field(default_factory=list, description="工时数据列表")


class ProduceBomManhourSummaryBatchSchema(BaseModel):
    bom_ids: list[int] = Field(default_factory=list, description="BOM ID列表")


class ProduceBomManhourQueryParam:
    """BOM工时关联查询参数"""

    def __init__(
        self,
        bom_id: int | None = Query(None, description="BOM ID"),
        craft_id: int | None = Query(None, description="工序ID"),
        manhour: int | None = Query(None, description="工时"),
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 精确查询字段
        if bom_id:
            self.bom_id = (QueueEnum.eq.value, bom_id)
        # 精确查询字段
        if craft_id:
            self.craft_id = (QueueEnum.eq.value, craft_id)
        # 精确查询字段
        if manhour:
            self.manhour = (QueueEnum.eq.value, manhour)
        # 时间范围查询
        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))
