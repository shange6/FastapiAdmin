# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from datetime import datetime
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class ProduceManhourCreateSchema(BaseModel):
    """
    工时管理新增模型
    """
    name: str = Field(default=..., description='零件名称')
    model: str = Field(default=..., description='零件型号')
    material: str = Field(default=..., description='材质')
    unit: str = Field(default=..., description='计算单位：g=重量 m=长度 p=件')
    unit_hour: int = Field(default=..., description='单位工时ms')
    blanking_ratio: int = Field(default=..., description='下料工时比率')
    welding_ratio: int = Field(default=..., description='铆焊工时比率')
    fitting_ratio: int = Field(default=..., description='装配工时比率')
    description: str | None = Field(default=None, max_length=255, description='备注/描述')


class ProduceManhourUpdateSchema(ProduceManhourCreateSchema):
    """
    工时管理更新模型
    """
    ...


class ProduceManhourOutSchema(ProduceManhourCreateSchema, BaseSchema, UserBySchema):
    """
    工时管理响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceManhourQueryParam:
    """工时管理查询参数"""

    def __init__(
        self,
        name: str | None = Query(None, description="零件名称"),
        model: str | None = Query(None, description="零件型号"),
        material: str | None = Query(None, description="材质"),
        unit: str | None = Query(None, description="计算单位：g=重量 m=长度 p=件"),
        unit_hour: int | None = Query(None, description="单位工时ms"),
        blanking_ratio: int | None = Query(None, description="下料工时比率"),
        welding_ratio: int | None = Query(None, description="铆焊工时比率"),
        fitting_ratio: int | None = Query(None, description="装配工时比率"),
        created_id: int | None = Query(None, description="创建人ID"),
        updated_id: int | None = Query(None, description="更新人ID"),
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 模糊查询字段
        self.name = (QueueEnum.like.value, name)
        # 精确查询字段
        if model:
            self.model = (QueueEnum.eq.value, model)
        # 精确查询字段
        if material:
            self.material = (QueueEnum.eq.value, material)
        # 精确查询字段
        if unit:
            self.unit = (QueueEnum.eq.value, unit)
        # 精确查询字段
        if unit_hour:
            self.unit_hour = (QueueEnum.eq.value, unit_hour)
        # 精确查询字段
        if blanking_ratio:
            self.blanking_ratio = (QueueEnum.eq.value, blanking_ratio)
        # 精确查询字段
        if welding_ratio:
            self.welding_ratio = (QueueEnum.eq.value, welding_ratio)
        # 精确查询字段
        if fitting_ratio:
            self.fitting_ratio = (QueueEnum.eq.value, fitting_ratio)
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
