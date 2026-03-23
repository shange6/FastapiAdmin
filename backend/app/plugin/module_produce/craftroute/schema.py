# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from datetime import datetime
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema


class CraftRouteViewOutSchema(BaseModel):
    """工艺路线视图输出模型"""
    model_config = ConfigDict(from_attributes=True)

    route_code: int = Field(..., description='工艺路线代号')
    route_name: str = Field(..., description='工艺路线名称')


class CraftRouteViewQuerySchema:
    """工艺路线视图查询参数"""

    def __init__(
        self,
        route_code: int | None = Query(None, description="工艺路线代号"),
        route_name: str | None = Query(None, description="工艺路线名称(模糊查询)"),
    ) -> None:
        self.route_name = route_name

class ProduceCraftRouteCreateSchema(BaseModel):
    """
    工艺路线新增模型
    """
    route: int = Field(default=..., description='工艺路线')
    sort: int = Field(default=..., description='排序')
    craft_id: int = Field(default=..., description='工艺ID')
    status: str = Field(default="0", description='是否启用(0:启用 1:禁用)')
    description: str | None = Field(default=None, max_length=255, description='备注/描述')


class ProduceCraftRouteUpdateSchema(ProduceCraftRouteCreateSchema):
    """
    工艺路线更新模型
    """
    ...


class ProduceCraftRouteOutSchema(ProduceCraftRouteCreateSchema, BaseSchema, UserBySchema):
    """
    工艺路线响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceCraftRouteQueryParam:
    """工艺路线查询参数"""

    def __init__(
        self,
        route: int | None = Query(None, description="工艺路线"),
        sort: int | None = Query(None, description="排序"),
        craft_id: int | None = Query(None, description="工艺ID"),
        status: str | None = Query(None, description="是否启用(0:启用 1:禁用)"),
        created_id: int | None = Query(None, description="创建人ID"),
        updated_id: int | None = Query(None, description="更新人ID"),
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 精确查询字段
        if route:
            self.route = (QueueEnum.eq.value, route)
        # 精确查询字段
        if sort:
            self.sort = (QueueEnum.eq.value, sort)
        # 精确查询字段
        if craft_id:
            self.craft_id = (QueueEnum.eq.value, craft_id)
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
