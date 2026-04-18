from typing import List, Optional
from pydantic import BaseModel, Field, field_validator

class LogEntrySchema(BaseModel):
    """解析日志条目"""
    status: str = Field(..., description="状态")
    msg: str = Field(..., description="消息")
    bom: Optional[dict] = Field(None, description="关联的BOM数据")

class UploadResponseSchema(BaseModel):
    """数据解析后的响应模型"""
    boms: List[dict] = Field(..., description="BOM列表")
    log: List[LogEntrySchema] = Field(..., description="解析日志")
    project_code: Optional[str] = Field(None, description="项目代号")
    project_name: Optional[str] = Field(None, description="项目名称")
    project_no: Optional[str] = Field(None, description="项目编号")
    first_code: Optional[str] = Field(None, description="根节点")
    file_count: int = Field(0, description="文件个数")

class ProjectImportSchema(BaseModel):
    """项目信息导入模型"""
    name: str = Field(..., description="项目名称")
    code: str = Field(..., description="项目编码")
    no: str = Field(..., description="项目编号")

class BomImportSchema(BaseModel):
    """零件信息导入模型"""
    project_code: str = Field(..., description="项目代号")
    parent_code: str = Field(..., description="父代号")
    first_code: str = Field(..., description="根代号")
    code: Optional[str] = Field(None, description="代号")
    spec: str = Field(..., description="名称/规格")
    count: int = Field(..., description="数量")
    material: Optional[str] = Field(None, description="材质")
    unit_mass: Optional[float] = Field(None, description="单重")
    total_mass: Optional[float] = Field(None, description="总重")
    remark: Optional[str] = Field(None, description="备注")
    borrow: Optional[bool] = Field(None, description="是否借用")
    procure: Optional[bool] = Field(None, description="是否外购")
    noimage: Optional[bool] = Field(None, description="是否无图")
    figure: Optional[bool] = Field(None, description="是否附图")

    @field_validator('unit_mass', 'total_mass', mode='before')
    def empty_to_none(cls, v):
        if v == "":
            return None
        return v

class SaveDataSchema(BaseModel):
    project: ProjectImportSchema
    bom: List[BomImportSchema]

class SaveDataResponseSchema(BaseModel):
    """保存数据的响应模型"""
    project_added: int = 0
    bom_added: int = 0
    duplicate_count: int = 0
    duplicate_logs: List[str] = []
