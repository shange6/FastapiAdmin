# -*- coding: utf-8 -*-

from fastapi import APIRouter, Depends, UploadFile, Body, Path, Query
from fastapi.responses import StreamingResponse, JSONResponse

from app.common.response import SuccessResponse, StreamResponse
from app.core.dependencies import AuthPermission
from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_params import PaginationQueryParam
from app.utils.common_util import bytes2file_response
from app.core.logger import log
from app.core.base_schema import BatchSetAvailable

from .service import DataBomService
from .schema import DataBomCreateSchema, DataBomUpdateSchema, DataBomQueryParam

DataBomRouter = APIRouter(prefix='/bom', tags=["BOM清单模块"]) 

@DataBomRouter.get(
    "/detail/{id}",
    summary="获取BOM清单详情",
    description="获取BOM清单详情"
)
async def get_bom_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:query"]))
) -> JSONResponse:
    """
    获取BOM清单详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含BOM清单详情的JSON响应
    """
    result_dict = await DataBomService.detail_bom_service(auth=auth, id=id)
    log.info(f"获取BOM清单详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取BOM清单详情成功")

@DataBomRouter.get(
    "/list",
    summary="查询BOM清单列表",
    description="查询BOM清单列表"
)
async def get_bom_list_controller(
    search: DataBomQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:query"]))
) -> JSONResponse:
    """
    查询BOM清单列表接口（不分页）
    
    参数:
    - search: DataBomQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含BOM清单列表的JSON响应
    """
    result_list = await DataBomService.list_bom_service(
        auth=auth,
        search=search
    )
    log.info("查询BOM清单列表成功")
    return SuccessResponse(data=result_list, msg="查询BOM清单列表成功")

@DataBomRouter.get(
    "/list/no-procure",
    summary="查询不需要采购的BOM清单列表",
    description="查询不需要采购的BOM清单列表"
)
async def get_bom_list_no_procure_controller(
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:query"]))
) -> JSONResponse:
    """
    查询不需要采购的BOM清单列表接口

    参数:
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含不需要采购的BOM清单列表的JSON响应
    """
    result_list = await DataBomService.list_bom_no_procure_service(auth=auth)
    log.info("查询不需要采购的BOM清单列表成功")
    return SuccessResponse(data=result_list, msg="查询不需要采购的BOM清单列表成功")

@DataBomRouter.post(
    "/create",
    summary="创建BOM清单",
    description="创建BOM清单"
)
async def create_bom_controller(
    data: DataBomCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:create"]))
) -> JSONResponse:
    """
    创建BOM清单接口
    
    参数:
    - data: DataBomCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建BOM清单结果的JSON响应
    """
    result_dict = await DataBomService.create_bom_service(auth=auth, data=data)
    log.info("创建BOM清单成功")
    return SuccessResponse(data=result_dict, msg="创建BOM清单成功")

@DataBomRouter.put(
    "/update/{id}",
    summary="修改BOM清单",
    description="修改BOM清单"
)
async def update_bom_controller(
    data: DataBomUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:update"]))
) -> JSONResponse:
    """
    修改BOM清单接口
    
    参数:
    - id: int - 数据ID
    - data: DataBomUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改BOM清单结果的JSON响应
    """
    result_dict = await DataBomService.update_bom_service(auth=auth, id=id, data=data)
    log.info("修改BOM清单成功")
    return SuccessResponse(data=result_dict, msg="修改BOM清单成功")

@DataBomRouter.delete(
    "/delete",
    summary="删除BOM清单",
    description="删除BOM清单"
)
async def delete_bom_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:delete"]))
) -> JSONResponse:
    """
    删除BOM清单接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除BOM清单结果的JSON响应
    """
    await DataBomService.delete_bom_service(auth=auth, ids=ids)
    log.info(f"删除BOM清单成功: {ids}")
    return SuccessResponse(msg="删除BOM清单成功")

@DataBomRouter.patch(
    "/available/setting",
    summary="批量修改BOM清单状态",
    description="批量修改BOM清单状态"
)
async def batch_set_available_bom_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:patch"]))
) -> JSONResponse:
    """
    批量修改BOM清单状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改BOM清单状态结果的JSON响应
    """
    await DataBomService.set_available_bom_service(auth=auth, data=data)
    log.info(f"批量修改BOM清单状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改BOM清单状态成功")

@DataBomRouter.post(
    '/export',
    summary="导出BOM清单",
    description="导出BOM清单"
)
async def export_bom_list_controller(
    search: DataBomQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:export"]))
) -> StreamingResponse:
    """
    导出BOM清单接口
    
    参数:
    - search: DataBomQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出BOM清单数据的流式响应
    """
    result_dict_list = await DataBomService.list_bom_service(search=search, auth=auth)
    export_result = await DataBomService.batch_export_bom_service(obj_list=result_dict_list)
    log.info('导出BOM清单成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=data_bom.xlsx'}
    )

@DataBomRouter.post(
    '/import',
    summary="导入BOM清单",
    description="导入BOM清单"
)
async def import_bom_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_data:bom:import"]))
) -> JSONResponse:
    """
    导入BOM清单接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入BOM清单结果的JSON响应
    """
    batch_import_result = await DataBomService.batch_import_bom_service(file=file, auth=auth, update_support=True)
    log.info("导入BOM清单成功")
    return SuccessResponse(data=batch_import_result, msg="导入BOM清单成功")

@DataBomRouter.post(
    '/download/template',
    summary="获取BOM清单导入模板",
    description="获取BOM清单导入模板",
    dependencies=[Depends(AuthPermission(["module_data:bom:download"]))]
)
async def export_bom_template_controller() -> StreamingResponse:
    """
    获取BOM清单导入模板接口
    
    返回:
    - StreamingResponse - 包含BOM清单导入模板的流式响应
    """
    import_template_result = await DataBomService.import_template_download_bom_service()
    log.info('获取BOM清单导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=data_bom_template.xlsx'}
    )