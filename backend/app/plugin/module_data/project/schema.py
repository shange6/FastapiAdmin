# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class DataProjectCreateSchema(BaseModel):
    """
    项目信息新增模型
    """
    code: str = Field(default=..., description='项目编码')
    name: str = Field(default=..., description='项目名称')
    no: str = Field(default=..., description='项目编号')


class DataProjectUpdateSchema(DataProjectCreateSchema):
    """
    项目信息更新模型
    """
    ...


class DataProjectOutSchema(DataProjectCreateSchema, BaseSchema, UserBySchema):
    """
    项目信息响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class DataProjectQueryParam:
    """项目信息查询参数"""

    def __init__(
        self,
        code: str | None = Query(None, description="项目编码"),
        name: str | None = Query(None, description="项目名称"),
        no: str | None = Query(None, description="项目编号"),
        keyword: str | None = Query(None, description="模糊搜索项目名称、编码或编号"),
        created_time: list[DateTimeStr] | None = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: list[DateTimeStr] | None = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
    ) -> None:
        # 模糊查询字段
        self.code = (QueueEnum.like.value, code)
        self.name = (QueueEnum.like.value, name)
        self.no = (QueueEnum.like.value, no)
        self.keyword = keyword
        # 精确查询字段
        # if no:
        #     self.no = (QueueEnum.eq.value, no)
        # 时间范围查询
        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))
