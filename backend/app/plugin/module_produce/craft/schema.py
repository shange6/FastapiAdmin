# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class ProduceCraftCreateSchema(BaseModel):
    """
    工艺字典新增模型
    """
    name: str = Field(default=..., description='工艺名称')


class ProduceCraftUpdateSchema(ProduceCraftCreateSchema):
    """
    工艺字典更新模型
    """
    ...


class ProduceCraftOutSchema(ProduceCraftCreateSchema, BaseSchema, UserBySchema):
    """
    工艺字典响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceCraftQueryParam:
    """工艺字典查询参数"""

    def __init__(
        self,
        name: str | None = Query(None, description="工艺名称"),
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 模糊查询字段
        self.name = (QueueEnum.like.value, name)
        # 时间范围查询
        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))
