# -*- coding: utf-8 -*-

from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from fastapi import Query
from app.core.validator import DateTimeStr
from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema

class DataBomCreateSchema(BaseModel):
    """
    BOM清单新增模型
    """
    # model_config = {"str_coerce_numbers": True}
    first_code: str = Field(..., description='根代号')
    parent_code: str = Field(..., description='父代号')
    code: Optional[str] = Field(default=None, description='代号')
    spec: str = Field(..., description='名称')
    count: int = Field(..., description='数量')
    material: Optional[str] = Field(default=None, description='材质')
    unit_mass: Optional[float] = Field(default=None, description='单重')
    total_mass: Optional[float] = Field(default=None, description='总重')
    remark: Optional[str] = Field(default=None, description='备注')
    borrow: bool = Field(default=False, description='是否借用')
    procure: bool = Field(default=False, description='是否外购')
    noimage: bool = Field(default=False, description='是否无图')
    figure: bool = Field(default=False, description='是否附图')
    status: str = Field(default="0", description='是否启用(0:启用 1:禁用)')
    description: Optional[str] = Field(default=None, max_length=255, description='描述')

    # ✅ 强制把空字符串变成 None
    @field_validator('unit_mass', 'total_mass', mode='before')
    def empty_to_none(cls, v):
        if v == "":
            return None
        return v


class DataBomUpdateSchema(BaseModel):
    """
    BOM清单更新模型
    """
    # model_config = {"str_coerce_numbers": True}
    parent_code: Optional[str] = Field(default=None, description='父代号（关联data_project.code）')
    first_code: Optional[str] = Field(default=None, description='根代号')
    code: Optional[str] = Field(default=None, description='代号')
    spec: Optional[str] = Field(default=None, description='名称')
    count: Optional[int] = Field(default=None, description='数量')
    material: Optional[str] = Field(default=None, description='材质')
    unit_mass: Optional[float] = Field(default=None, description='单重')
    total_mass: Optional[float] = Field(default=None, description='总重')
    remark: Optional[str] = Field(default=None, description='备注')
    borrow: Optional[bool] = Field(default=None, description='是否借用')
    procure: Optional[bool] = Field(default=None, description='是否外购')
    noimage: Optional[bool] = Field(default=None, description='是否无图')
    figure: Optional[bool] = Field(default=None, description='是否附图')
    status: Optional[str] = Field(default=None, description='是否启用(0:启用 1:禁用)')
    description: Optional[str] = Field(default=None, max_length=255, description='描述')

    # ✅ 强制把空字符串变成 None
    @field_validator('unit_mass', 'total_mass', mode='before')
    def empty_to_none(cls, v):
        if v == "":
            return None
        return v

class DataBomOutSchema(DataBomCreateSchema, BaseSchema, UserBySchema):
    """
    BOM清单响应模型
    """
    model_config = ConfigDict(from_attributes=True)


class DataBomQueryParam:
    """BOM清单查询参数"""

    def __init__(
        self,
        parent_code: Optional[str] = Query(None, description="父代号（关联data_project.code）"),
        first_code: Optional[str] = Query(None, description="根代号"),
        code: Optional[str] = Query(None, description="代号"),
        spec: Optional[str] = Query(None, description="名称"),
        count: Optional[int] = Query(None, description="数量"),
        material: Optional[str] = Query(None, description="材质"),
        unit_mass: Optional[float] = Query(None, description="单重"),
        total_mass: Optional[float] = Query(None, description="总重"),
        remark: Optional[str] = Query(None, description="备注"),
        borrow: Optional[bool] = Query(None, description="是否借用"),
        procure: Optional[bool] = Query(None, description="是否外购"),
        noimage: Optional[bool] = Query(None, description="是否无图"),
        figure: Optional[bool] = Query(None, description="是否附图"),
        status: Optional[str] = Query(None, description="是否启用(0:启用 1:禁用)"),
        created_id: Optional[int] = Query(None, description="创建人ID"),
        updated_id: Optional[int] = Query(None, description="更新人ID"),
        created_time: Optional[list[DateTimeStr]] = Query(None, description="创建时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        updated_time: Optional[list[DateTimeStr]] = Query(None, description="更新时间范围", examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"]),
        recursive: bool = Query(False, description="是否递归查询后代"),
    ) -> None:
        self.parent_code = parent_code
        self.first_code = first_code
        self.code = code
        self.spec = spec
        self.count = count
        self.material = material
        self.unit_mass = unit_mass
        self.total_mass = total_mass
        self.remark = remark
        self.borrow = borrow
        self.procure = procure
        self.noimage = noimage
        self.figure = figure
        self.status = status
        self.created_id = created_id
        self.updated_id = updated_id
        self.created_time = created_time
        self.updated_time = updated_time
        self.recursive = recursive
        # 精确查询字段
        if parent_code:
            self.parent_code = (QueueEnum.eq.value, parent_code)
        # 精确查询字段
        if first_code:
            self.first_code = (QueueEnum.eq.value, first_code)
        # 模糊查询字段
        if code:
            self.code = (QueueEnum.like.value, code)
        # 模糊查询字段
        if spec:
            self.spec = (QueueEnum.like.value, spec)
        # 精确查询字段
        if count:
            self.count = (QueueEnum.eq.value, count)
        # 模糊查询字段
        if material:
            self.material = (QueueEnum.like.value, material)
        # 精确查询字段
        if unit_mass:
            self.unit_mass = (QueueEnum.eq.value, unit_mass)
        # 精确查询字段
        if total_mass:
            self.total_mass = (QueueEnum.eq.value, total_mass)
        # 模糊查询字段
        if remark:
            self.remark = (QueueEnum.like.value, remark)
        # 精确查询字段
        if borrow is not None:
            self.borrow = (QueueEnum.eq.value, borrow)
        # 精确查询字段
        if procure is not None:
            self.procure = (QueueEnum.eq.value, procure)
        # 精确查询字段
        if noimage is not None:
            self.noimage = (QueueEnum.eq.value, noimage)
        # 精确查询字段
        if figure is not None:
            self.figure = (QueueEnum.eq.value, figure)
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
