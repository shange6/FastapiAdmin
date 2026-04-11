# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from datetime import datetime
from datetime import date
from app.core.validator import DateTimeStr
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class ProduceOrderCreateSchema(BaseModel):
    """
    工单新增模型
    """
    no: str | None = Field(default=None, description='单号')
    bom_id: int = Field(default=..., description='BOM ID')
    craft_id: int = Field(default=..., description='子工艺ID')
    man_hour: int = Field(default=..., description='工时')
    plan_count: int = Field(default=..., description='计划数量')
    real_count: int | None = Field(default=None, description='实际数量')
    plan_date: date = Field(default=..., description='计划日期')
    real_date: date | None = Field(default=None, description='实际日期')
    plan_user: int = Field(default=..., description='计划用户ID')
    real_user: int | None = Field(default=None, description='实际用户ID')
    status: str = Field(default="0", description='状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停')
    description: str | None = Field(default=None, max_length=255, description='备注/描述')


class ProduceOrderUpdateSchema(ProduceOrderCreateSchema):
    """
    工单更新模型
    """
    ...


class ProduceOrderOutSchema(ProduceOrderCreateSchema, BaseSchema, UserBySchema):
    """
    工单响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceOrderQueryParam:
    """工单查询参数"""

    def __init__(
        self,
        bom_id: int | None = Query(None, description="BOM ID"),
        craft_id: int | None = Query(None, description="子工艺ID"),
        man_hour: int | None = Query(None, description="工时"),
        plan_count: int | None = Query(None, description="计划数量"),
        real_count: int | None = Query(None, description="实际数量"),
        plan_date: date | None = Query(None, description="计划日期"),
        real_date: date | None = Query(None, description="实际日期"),
        status: str | None = Query(None, description="状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停"),
        created_id: int | None = Query(None, description="创建人ID"),
        updated_id: int | None = Query(None, description="更新人ID"),
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
        if man_hour:
            self.man_hour = (QueueEnum.eq.value, man_hour)
        # 精确查询字段
        if plan_count:
            self.plan_count = (QueueEnum.eq.value, plan_count)
        # 精确查询字段
        if real_count:
            self.real_count = (QueueEnum.eq.value, real_count)
        # 精确查询字段
        if plan_date:
            self.plan_date = (QueueEnum.eq.value, plan_date)
        # 精确查询字段
        if real_date:
            self.real_date = (QueueEnum.eq.value, real_date)
        # 精确查询字段
        if status:
            self.status = (QueueEnum.eq.value, status)
        # 精确查询字段
        if created_id:
            self.created_id = (QueueEnum.eq.value, created_id)
        # 精确查询字段
        if updated_id:
            self.updated_id = (QueueEnum.eq.value, updated_id)
        # 时间范围查询
        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))


class ProduceOrderSummaryBatchSchema(BaseModel):
    bom_ids: list[int] = Field(default_factory=list, description="BOM ID列表")


class ProduceOrderUpsertItemSchema(BaseModel):
    no: str | None = Field(default=None, description="单号")
    bom_id: int = Field(default=..., description="BOM ID")
    craft_id: int = Field(default=..., description="子工艺ID")
    man_hour: int = Field(default=..., description="工时")
    plan_date: date = Field(default=..., description="计划日期")
    plan_user: int = Field(default=..., description="计划用户ID")
    plan_count: int = Field(default=1, description="计划数量")
    real_count: int = Field(default=0, description="实际数量")
    real_date: date | None = Field(default=None, description="实际日期")
    status: str = Field(default="0", description='状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停')
    description: str | None = Field(default=None, description="备注")


class ProduceOrderUpsertBatchSchema(BaseModel):
    items: list[ProduceOrderUpsertItemSchema] = Field(default_factory=list, description="工单列表")
