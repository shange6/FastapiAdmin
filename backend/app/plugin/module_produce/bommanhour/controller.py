# -*- coding: utf-8 -*-

from fastapi import APIRouter, Depends, UploadFile, Body, Path, Query, Request
from fastapi.responses import StreamingResponse, JSONResponse

from app.common.response import SuccessResponse, StreamResponse
from app.core.dependencies import AuthPermission
from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_params import PaginationQueryParam
from app.utils.common_util import bytes2file_response
from app.core.logger import log
from app.core.base_schema import BatchSetAvailable

from .service import ProduceBomManhourService
from .schema import (
    ProduceBomManhourCreateSchema,
    ProduceBomManhourUpdateSchema,
    ProduceBomManhourQueryParam,
    ProduceBomManhourUpsertBatchSchema,
    ProduceBomManhourSummaryBatchSchema,
)

ProduceBomManhourRouter = APIRouter(prefix='/bommanhour', tags=["BOM工时关联模块"]) 

@ProduceBomManhourRouter.get(
    "/detail/{id}",
    summary="获取BOM工时关联详情",
    description="获取BOM工时关联详情"
)
async def get_bommanhour_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    """
    获取BOM工时关联详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含BOM工时关联详情的JSON响应
    """
    result_dict = await ProduceBomManhourService.detail_bommanhour_service(auth=auth, id=id)
    log.info(f"获取BOM工时关联详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取BOM工时关联详情成功")

@ProduceBomManhourRouter.get(
    "/list",
    summary="查询BOM工时关联列表",
    description="查询BOM工时关联列表"
)
async def get_bommanhour_list_controller(
    request: Request,
    page: PaginationQueryParam = Depends(),
    search: ProduceBomManhourQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    """
    查询BOM工时关联列表接口（数据库分页）
    
    参数:
    - page: PaginationQueryParam - 分页参数
    - search: ProduceBomManhourQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含BOM工时关联列表的JSON响应
    """
    has_pagination = ("page_no" in request.query_params) or ("page_size" in request.query_params)
    order_by = page.order_by if ("order_by" in request.query_params) else None

    if not has_pagination:
        result = await ProduceBomManhourService.list_bommanhour_service(
            auth=auth, search=search, order_by=order_by
        )
        log.info("查询BOM工时关联列表成功(全量)")
        return SuccessResponse(data=result, msg="查询BOM工时关联列表成功")

    result_dict = await ProduceBomManhourService.page_bommanhour_service(
        auth=auth,
        page_no=page.page_no,
        page_size=page.page_size,
        search=search,
        order_by=order_by,
    )
    log.info("查询BOM工时关联列表成功")
    return SuccessResponse(data=result_dict, msg="查询BOM工时关联列表成功")

@ProduceBomManhourRouter.post(
    "/create",
    summary="创建BOM工时关联",
    description="创建BOM工时关联"
)
async def create_bommanhour_controller(
    data: ProduceBomManhourCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:create"]))
) -> JSONResponse:
    """
    创建BOM工时关联接口
    
    参数:
    - data: ProduceBomManhourCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建BOM工时关联结果的JSON响应
    """
    result_dict = await ProduceBomManhourService.create_bommanhour_service(auth=auth, data=data)
    log.info("创建BOM工时关联成功")
    return SuccessResponse(data=result_dict, msg="创建BOM工时关联成功")

@ProduceBomManhourRouter.post(
    "/upsert/batch",
    summary="批量保存BOM工时",
    description="批量插入/更新/删除BOM工时：manhour>0 插入或更新，manhour<=0 删除（如存在）"
)
async def upsert_batch_bommanhour_controller(
    data: ProduceBomManhourUpsertBatchSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:update"]))
) -> JSONResponse:
    result = await ProduceBomManhourService.upsert_batch_bommanhour_service(auth=auth, payload=data)
    log.info(f"批量Upsert BOM工时关联成功: {len(data.items)} 条")
    return SuccessResponse(data=result, msg="批量保存工时成功")

@ProduceBomManhourRouter.get(
    "/summary/missing/count/by-project-id/{project_id}",
    summary="根据项目ID统计缺失工时数量",
    description="根据项目ID统计缺失工时数量，返回差额"
)
async def summary_missing_manhour_count_by_project_id_controller(
    project_id: int = Path(..., description="项目ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    result = await ProduceBomManhourService.summary_missing_manhour_count_by_project_id_service(auth=auth, project_id=project_id)
    return SuccessResponse(data=result, msg="查询成功")

@ProduceBomManhourRouter.get(
    "/summary/missing/count/by-first-id/{first_id}",
    summary="根据first_id统计缺失工时数量",
    description="根据点击的BOM的ID统计缺失工时数量，返回差额"
)
async def summary_missing_manhour_count_by_first_id_controller(
    first_id: int = Path(..., description="BOM ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    result = await ProduceBomManhourService.summary_missing_manhour_count_by_first_id_service(auth=auth, first_id=first_id)
    return SuccessResponse(data=result, msg="查询成功")

@ProduceBomManhourRouter.post(
    "/summary/batch",
    summary="批量查询BOM工时汇总",
    description="按BOM ID批量查询工时，支持递归汇总后代节点工时"
)
async def summary_batch_bommanhour_controller(
    data: ProduceBomManhourSummaryBatchSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    result_dict = await ProduceBomManhourService.summary_batch_bommanhour_service(
        auth=auth, bom_ids=data.bom_ids, recursive=data.recursive
    )
    return SuccessResponse(data=result_dict, msg="查询成功")

@ProduceBomManhourRouter.post(
    "/summary/craft/batch",
    summary="批量查询BOM工时（按工艺汇总）",
    description="按BOM ID批量查询工时，并按工艺名称汇总"
)
async def summary_craft_batch_bommanhour_controller(
    data: ProduceBomManhourSummaryBatchSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:query"]))
) -> JSONResponse:
    result_dict = await ProduceBomManhourService.summary_craft_batch_bommanhour_service(auth=auth, bom_ids=data.bom_ids)
    return SuccessResponse(data=result_dict, msg="查询成功")

@ProduceBomManhourRouter.put(
    "/update/{id}",
    summary="修改BOM工时关联",
    description="修改BOM工时关联"
)
async def update_bommanhour_controller(
    data: ProduceBomManhourUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:update"]))
) -> JSONResponse:
    """
    修改BOM工时关联接口
    
    参数:
    - id: int - 数据ID
    - data: ProduceBomManhourUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改BOM工时关联结果的JSON响应
    """
    result_dict = await ProduceBomManhourService.update_bommanhour_service(auth=auth, id=id, data=data)
    log.info("修改BOM工时关联成功")
    return SuccessResponse(data=result_dict, msg="修改BOM工时关联成功")

@ProduceBomManhourRouter.delete(
    "/delete",
    summary="删除BOM工时关联",
    description="删除BOM工时关联"
)
async def delete_bommanhour_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:delete"]))
) -> JSONResponse:
    """
    删除BOM工时关联接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除BOM工时关联结果的JSON响应
    """
    await ProduceBomManhourService.delete_bommanhour_service(auth=auth, ids=ids)
    log.info(f"删除BOM工时关联成功: {ids}")
    return SuccessResponse(msg="删除BOM工时关联成功")

@ProduceBomManhourRouter.patch(
    "/available/setting",
    summary="批量修改BOM工时关联状态",
    description="批量修改BOM工时关联状态"
)
async def batch_set_available_bommanhour_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:patch"]))
) -> JSONResponse:
    """
    批量修改BOM工时关联状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改BOM工时关联状态结果的JSON响应
    """
    await ProduceBomManhourService.set_available_bommanhour_service(auth=auth, data=data)
    log.info(f"批量修改BOM工时关联状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改BOM工时关联状态成功")

@ProduceBomManhourRouter.post(
    '/export',
    summary="导出BOM工时关联",
    description="导出BOM工时关联"
)
async def export_bommanhour_list_controller(
    search: ProduceBomManhourQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:export"]))
) -> StreamingResponse:
    """
    导出BOM工时关联接口
    
    参数:
    - search: ProduceBomManhourQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出BOM工时关联数据的流式响应
    """
    result_dict_list = await ProduceBomManhourService.list_bommanhour_service(search=search, auth=auth)
    export_result = await ProduceBomManhourService.batch_export_bommanhour_service(obj_list=result_dict_list)
    log.info('导出BOM工时关联成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_bom_manhour.xlsx'}
    )

@ProduceBomManhourRouter.post(
    '/import',
    summary="导入BOM工时关联",
    description="导入BOM工时关联"
)
async def import_bommanhour_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bommanhour:import"]))
) -> JSONResponse:
    """
    导入BOM工时关联接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入BOM工时关联结果的JSON响应
    """
    batch_import_result = await ProduceBomManhourService.batch_import_bommanhour_service(file=file, auth=auth, update_support=True)
    log.info("导入BOM工时关联成功")
    return SuccessResponse(data=batch_import_result, msg="导入BOM工时关联成功")

@ProduceBomManhourRouter.post(
    '/download/template',
    summary="获取BOM工时关联导入模板",
    description="获取BOM工时关联导入模板",
    dependencies=[Depends(AuthPermission(["module_produce:bommanhour:download"]))]
)
async def export_bommanhour_template_controller() -> StreamingResponse:
    """
    获取BOM工时关联导入模板接口
    
    返回:
    - StreamingResponse - 包含BOM工时关联导入模板的流式响应
    """
    import_template_result = await ProduceBomManhourService.import_template_download_bommanhour_service()
    log.info('获取BOM工时关联导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_bom_manhour_template.xlsx'}
    )
