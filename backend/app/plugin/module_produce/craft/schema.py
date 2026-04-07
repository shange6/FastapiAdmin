# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from fastapi import Query
from app.common.enums import QueueEnum
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


class ProduceCraftOutSchema(ProduceCraftCreateSchema):
    """
    工艺字典响应模型
    """
    model_config = ConfigDict(from_attributes=True)
    id: int = Field(description="工艺ID")


class ProduceCraftQueryParam:
    """工艺字典查询参数"""

    def __init__(
        self,
        name: str | None = Query(None, description="工艺名称"),
    ) -> None:
        # 模糊查询字段
        self.name = (QueueEnum.like.value, name)
