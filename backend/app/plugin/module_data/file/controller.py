# -*- coding: utf-8 -*-

from typing import Annotated
from fastapi import APIRouter, Depends, UploadFile, Body, Path, Query, Request, Form
from fastapi.responses import StreamingResponse, JSONResponse

from app.common.response import SuccessResponse, StreamResponse, ErrorResponse
from app.core.dependencies import AuthPermission
from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_params import PaginationQueryParam
from app.utils.common_util import bytes2file_response
from app.core.logger import log
from app.core.base_schema import BatchSetAvailable

from .service import DataFileService
from .schema import UploadResponseSchema, SaveDataSchema

DataFileRouter = APIRouter(prefix='/file', tags=["文件导入模块"]) 

@DataFileRouter.post(
    "/upload",
    summary="上传文件",
    description="上传文件到指定目录",
    dependencies=[Depends(AuthPermission(["module_data:file:create"]))],
)
async def upload_file_controller(
    file: UploadFile,
    request: Request,
    target_path: Annotated[str | None, Form(description="目标目录路径")] = None,
) -> JSONResponse:
    """
    上传文件

    参数:
    - file (UploadFile): 要上传的文件对象。
    - request (Request): FastAPI请求对象，用于获取基础URL。
    - target_path (str | None): 目标目录路径，默认为None。

    返回:
    - JSONResponse: 包含上传文件信息的JSON响应。
    """
    result = await DataFileService.upload_file_service(
        file=file, target_path=target_path, base_url=str(request.base_url)
    )
    # log.info(f"上传文件成功: {result_dict['file_name']}")
    return SuccessResponse(
        data=result, 
        msg="文件处理成功"
    )

@DataFileRouter.post(
    "/save_data",
    summary="保存项目信息",
    description="保存解析后的数据到数据库",
)
async def save_data_controller(
    payload: SaveDataSchema,
    current_user: Annotated[AuthSchema, Depends(AuthPermission(["module_data:file:create"]))],
) -> JSONResponse:
    """
    保存前端数据到数据库
    """
    result = await DataFileService.save_data_service(current_user, payload)
    if result.duplicate_count > 0:
        msg = f"发现 {result.duplicate_count} 条重复BOM项"
        return ErrorResponse(data=result, msg=msg)

    msg = f"保存数据成功! 新增项目: {result.project_added}, 新增BOM项: {result.bom_added}"
    log.info(msg)
    return SuccessResponse(data=result, msg=msg)
