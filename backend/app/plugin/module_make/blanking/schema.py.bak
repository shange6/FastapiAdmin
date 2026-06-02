# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from datetime import datetime
from app.core.validator import DateTimeStr
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

import json

class ProduceMakeCreateSchema(BaseModel):
    """
    制造流程主新增模型
    """
    project_code: str | None = Field(default=None, description='项目代码')
    first_code: str | None = Field(default=None, description='一级代号')
    bom_id: int = Field(default=..., description='BOMID')
    order_no: str = Field(default=..., description='单号')
    current_sort: int = Field(default=..., description='工艺序号')
    current_craft_id: int = Field(default=..., description='工艺ID')
    status: str = Field(default="0", description='状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停')
    description: str | None = Field(default=None, max_length=255, description='备注/描述')


class ProduceMakeUpdateSchema(ProduceMakeCreateSchema):
    """
    制造流程主更新模型
    """
    ...


class ProduceMakeOutSchema(ProduceMakeCreateSchema, BaseSchema, UserBySchema):
    """
    制造流程主响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class ProduceMakeQueryParam:
    """制造流程主查询参数"""

    def __init__(
        self,
        bom_id: int | None = Query(None, description="BOMID"),
        order_no: str | None = Query(None, description="单号"),
        project_code: str | None = Query(None, description="项目代码"),
        first_code: str | None = Query(None, description="一级代号"),
        current_sort: int | None = Query(None, description="工艺序号"),
        current_craft_id: int | None = Query(None, description="工艺ID"),
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
        if order_no:
            self.order_no = (QueueEnum.eq.value, order_no)
        # 精确查询字段
        if project_code:
            self.project_code = (QueueEnum.eq.value, project_code)
        # 精确查询字段
        if first_code:
            self.first_code = (QueueEnum.eq.value, first_code)
        # 精确查询字段
        if current_sort:
            self.current_sort = (QueueEnum.eq.value, current_sort)
        # 精确查询字段
        if current_craft_id:
            self.current_craft_id = (QueueEnum.eq.value, current_craft_id)
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


class ProduceMakePaginationQueryParam:
    """制造流程主分页查询参数(可选分页)"""

    def __init__(
        self,
        page_no: int | None = Query(default=None, description="当前页码", ge=1),
        page_size: int | None = Query(default=None, description="每页数量", ge=1, le=1000),
        order_by: str | None = Query(
            default=None,
            description="排序字段,格式:[{'field1': 'asc'}, {'field2': 'desc'}]",
        ),
    ) -> None:
        self.page_no = page_no
        self.page_size = page_size
        if order_by:
            try:
                self.order_by = json.loads(order_by)
            except ValueError:
                self.order_by = [{"updated_time": "desc"}]
        else:
            self.order_by = [{"updated_time": "desc"}]


class ProduceMakeFlowCreateSchema(BaseModel):
    """
    制造流程执行记录新增模型
    """
    project_code: str | None = Field(default=None, description='项目代码')
    first_code: str | None = Field(default=None, description='一级代号')
    make_id: int = Field(default=..., description='制造ID')
    bom_id: int = Field(default=..., description='BOMID')
    user_id: int = Field(default=..., description='用户ID')
    sort: int = Field(default=..., description='工艺序号')
    craft_id: int = Field(default=..., description='工艺ID')
    end_time: datetime = Field(default_factory=datetime.now, description='完工时间')


class ProduceMakeFlowBatchCreateSchema(BaseModel):
    """
    制造流程执行记录批量新增模型
    """
    items: list[ProduceMakeFlowCreateSchema] = Field(..., description='执行记录列表')


class ProduceMakeFlowOutSchema(ProduceMakeFlowCreateSchema, BaseSchema, UserBySchema):
    """
    制造流程执行记录响应模型
    """
    model_config = ConfigDict(from_attributes=True)
