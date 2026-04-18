# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class ProduceBomRouteCreateSchema(BaseModel):
    """
    BOM路线关联新增模型
    """
    project_code: str = Field(default=..., description='项目编码')
    first_code: str = Field(default=..., description='一级代号')
    bom_id: int = Field(default=..., description='BOMID')
    route: int = Field(default=..., description='工艺路线')


class ProduceBomRouteUpdateSchema(ProduceBomRouteCreateSchema):
    """
    BOM路线关联更新模型
    """
    ...


class ProduceBomRouteOutSchema(ProduceBomRouteCreateSchema, BaseSchema, UserBySchema):
    """
    BOM路线关联响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceBomRouteQueryParam:
    """BOM路线关联查询参数"""

    def __init__(
        self,
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 时间范围查询
        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))
