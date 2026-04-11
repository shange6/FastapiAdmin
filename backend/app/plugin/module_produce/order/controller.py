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

from .service import ProduceOrderService
from .schema import (
    ProduceOrderCreateSchema,
    ProduceOrderUpdateSchema,
    ProduceOrderQueryParam,
    ProduceOrderSummaryBatchSchema,
    ProduceOrderUpsertBatchSchema,
)

ProduceOrderRouter = APIRouter(prefix='/order', tags=["工单模块"]) 

@ProduceOrderRouter.get(
    "/detail/{id}",
    summary="获取工单详情",
    description="获取工单详情"
)
async def get_order_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:query"]))
) -> JSONResponse:
    """
    获取工单详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含工单详情的JSON响应
    """
    result_dict = await ProduceOrderService.detail_order_service(auth=auth, id=id)
    log.info(f"获取工单详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取工单详情成功")

@ProduceOrderRouter.get(
    "/list",
    summary="查询工单列表",
    description="查询工单列表"
)
async def get_order_list_controller(
    page: PaginationQueryParam = Depends(),
    search: ProduceOrderQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:query"]))
) -> JSONResponse:
    """
    查询工单列表接口（数据库分页）
    
    参数:
    - page: PaginationQueryParam - 分页参数
    - search: ProduceOrderQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含工单列表的JSON响应
    """
    result_dict = await ProduceOrderService.page_order_service(
        auth=auth,
        page_no=page.page_no if page.page_no is not None else 1,
        page_size=page.page_size if page.page_size is not None else 10,
        search=search,
        order_by=page.order_by
    )
    log.info("查询工单列表成功")
    return SuccessResponse(data=result_dict, msg="查询工单列表成功")

@ProduceOrderRouter.post(
    "/summary/batch",
    summary="批量查询工单单号",
    description="按BOM ID批量查询工单ID，并用逗号拼接成字符串"
)
async def summary_batch_order_controller(
    data: ProduceOrderSummaryBatchSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:query"]))
) -> JSONResponse:
    result_dict = await ProduceOrderService.summary_batch_order_service(auth=auth, bom_ids=data.bom_ids)
    return SuccessResponse(data=result_dict, msg="查询成功")

@ProduceOrderRouter.post(
    "/upsert/batch",
    summary="批量保存工单（存在则更新，不存在则创建）",
    description="按BOM与子工艺唯一键进行批量保存"
)
async def upsert_batch_order_controller(
    data: ProduceOrderUpsertBatchSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:create"]))
) -> JSONResponse:
    result_dict = await ProduceOrderService.upsert_batch_order_service(auth=auth, data=data)
    log.info("批量保存工单成功")
    return SuccessResponse(data=result_dict, msg="批量保存工单成功")

@ProduceOrderRouter.post(
    "/create",
    summary="创建工单",
    description="创建工单"
)
async def create_order_controller(
    data: ProduceOrderCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:create"]))
) -> JSONResponse:
    """
    创建工单接口
    
    参数:
    - data: ProduceOrderCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建工单结果的JSON响应
    """
    result_dict = await ProduceOrderService.create_order_service(auth=auth, data=data)
    log.info("创建工单成功")
    return SuccessResponse(data=result_dict, msg="创建工单成功")

@ProduceOrderRouter.put(
    "/update/{id}",
    summary="修改工单",
    description="修改工单"
)
async def update_order_controller(
    data: ProduceOrderUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:update"]))
) -> JSONResponse:
    """
    修改工单接口
    
    参数:
    - id: int - 数据ID
    - data: ProduceOrderUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改工单结果的JSON响应
    """
    result_dict = await ProduceOrderService.update_order_service(auth=auth, id=id, data=data)
    log.info("修改工单成功")
    return SuccessResponse(data=result_dict, msg="修改工单成功")

@ProduceOrderRouter.delete(
    "/delete",
    summary="删除工单",
    description="删除工单"
)
async def delete_order_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:delete"]))
) -> JSONResponse:
    """
    删除工单接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除工单结果的JSON响应
    """
    await ProduceOrderService.delete_order_service(auth=auth, ids=ids)
    log.info(f"删除工单成功: {ids}")
    return SuccessResponse(msg="删除工单成功")

@ProduceOrderRouter.patch(
    "/available/setting",
    summary="批量修改工单状态",
    description="批量修改工单状态"
)
async def batch_set_available_order_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:patch"]))
) -> JSONResponse:
    """
    批量修改工单状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改工单状态结果的JSON响应
    """
    await ProduceOrderService.set_available_order_service(auth=auth, data=data)
    log.info(f"批量修改工单状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改工单状态成功")

@ProduceOrderRouter.post(
    '/export',
    summary="导出工单",
    description="导出工单"
)
async def export_order_list_controller(
    search: ProduceOrderQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:export"]))
) -> StreamingResponse:
    """
    导出工单接口
    
    参数:
    - search: ProduceOrderQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出工单数据的流式响应
    """
    result_dict_list = await ProduceOrderService.list_order_service(search=search, auth=auth)
    export_result = await ProduceOrderService.batch_export_order_service(obj_list=result_dict_list)
    log.info('导出工单成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_order.xlsx'}
    )

@ProduceOrderRouter.post(
    '/import',
    summary="导入工单",
    description="导入工单"
)
async def import_order_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:order:import"]))
) -> JSONResponse:
    """
    导入工单接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入工单结果的JSON响应
    """
    batch_import_result = await ProduceOrderService.batch_import_order_service(file=file, auth=auth, update_support=True)
    log.info("导入工单成功")
    return SuccessResponse(data=batch_import_result, msg="导入工单成功")

@ProduceOrderRouter.post(
    '/download/template',
    summary="获取工单导入模板",
    description="获取工单导入模板",
    dependencies=[Depends(AuthPermission(["module_produce:order:download"]))]
)
async def export_order_template_controller() -> StreamingResponse:
    """
    获取工单导入模板接口
    
    返回:
    - StreamingResponse - 包含工单导入模板的流式响应
    """
    import_template_result = await ProduceOrderService.import_template_download_order_service()
    log.info('获取工单导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_order_template.xlsx'}
    )
