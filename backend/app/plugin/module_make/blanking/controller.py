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

from .service import ProduceMakeService
from .schema import ProduceMakeCreateSchema, ProduceMakeUpdateSchema, ProduceMakeQueryParam

ProduceMakeRouter = APIRouter(prefix='/blanking', tags=["制造流程主模块"]) 

@ProduceMakeRouter.get(
    "/detail/{id}",
    summary="获取制造流程主详情",
    description="获取制造流程主详情"
)
async def get_blanking_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:query"]))
) -> JSONResponse:
    """
    获取制造流程主详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含制造流程主详情的JSON响应
    """
    result_dict = await ProduceMakeService.detail_blanking_service(auth=auth, id=id)
    log.info(f"获取制造流程主详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取制造流程主详情成功")

@ProduceMakeRouter.get(
    "/list",
    summary="查询制造流程主列表",
    description="查询制造流程主列表"
)
async def get_blanking_list_controller(
    page: PaginationQueryParam = Depends(),
    search: ProduceMakeQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:query"]))
) -> JSONResponse:
    """
    查询制造流程主列表接口（数据库分页）
    
    参数:
    - page: PaginationQueryParam - 分页参数
    - search: ProduceMakeQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含制造流程主列表的JSON响应
    """
    result_dict = await ProduceMakeService.page_blanking_service(
        auth=auth,
        page_no=page.page_no if page.page_no is not None else 1,
        page_size=page.page_size if page.page_size is not None else 10,
        search=search,
        order_by=page.order_by
    )
    log.info("查询制造流程主列表成功")
    return SuccessResponse(data=result_dict, msg="查询制造流程主列表成功")

@ProduceMakeRouter.post(
    "/create",
    summary="创建制造流程主",
    description="创建制造流程主"
)
async def create_blanking_controller(
    data: ProduceMakeCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:create"]))
) -> JSONResponse:
    """
    创建制造流程主接口
    
    参数:
    - data: ProduceMakeCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建制造流程主结果的JSON响应
    """
    result_dict = await ProduceMakeService.create_blanking_service(auth=auth, data=data)
    log.info("创建制造流程主成功")
    return SuccessResponse(data=result_dict, msg="创建制造流程主成功")

@ProduceMakeRouter.put(
    "/update/{id}",
    summary="修改制造流程主",
    description="修改制造流程主"
)
async def update_blanking_controller(
    data: ProduceMakeUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:update"]))
) -> JSONResponse:
    """
    修改制造流程主接口
    
    参数:
    - id: int - 数据ID
    - data: ProduceMakeUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改制造流程主结果的JSON响应
    """
    result_dict = await ProduceMakeService.update_blanking_service(auth=auth, id=id, data=data)
    log.info("修改制造流程主成功")
    return SuccessResponse(data=result_dict, msg="修改制造流程主成功")

@ProduceMakeRouter.delete(
    "/delete",
    summary="删除制造流程主",
    description="删除制造流程主"
)
async def delete_blanking_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:delete"]))
) -> JSONResponse:
    """
    删除制造流程主接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除制造流程主结果的JSON响应
    """
    await ProduceMakeService.delete_blanking_service(auth=auth, ids=ids)
    log.info(f"删除制造流程主成功: {ids}")
    return SuccessResponse(msg="删除制造流程主成功")

@ProduceMakeRouter.patch(
    "/available/setting",
    summary="批量修改制造流程主状态",
    description="批量修改制造流程主状态"
)
async def batch_set_available_blanking_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:patch"]))
) -> JSONResponse:
    """
    批量修改制造流程主状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改制造流程主状态结果的JSON响应
    """
    await ProduceMakeService.set_available_blanking_service(auth=auth, data=data)
    log.info(f"批量修改制造流程主状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改制造流程主状态成功")

@ProduceMakeRouter.post(
    '/export',
    summary="导出制造流程主",
    description="导出制造流程主"
)
async def export_blanking_list_controller(
    search: ProduceMakeQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:export"]))
) -> StreamingResponse:
    """
    导出制造流程主接口
    
    参数:
    - search: ProduceMakeQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出制造流程主数据的流式响应
    """
    result_dict_list = await ProduceMakeService.list_blanking_service(search=search, auth=auth)
    export_result = await ProduceMakeService.batch_export_blanking_service(obj_list=result_dict_list)
    log.info('导出制造流程主成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_make.xlsx'}
    )

@ProduceMakeRouter.post(
    '/import',
    summary="导入制造流程主",
    description="导入制造流程主"
)
async def import_blanking_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_make:blanking:import"]))
) -> JSONResponse:
    """
    导入制造流程主接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入制造流程主结果的JSON响应
    """
    batch_import_result = await ProduceMakeService.batch_import_blanking_service(file=file, auth=auth, update_support=True)
    log.info("导入制造流程主成功")
    return SuccessResponse(data=batch_import_result, msg="导入制造流程主成功")

@ProduceMakeRouter.post(
    '/download/template',
    summary="获取制造流程主导入模板",
    description="获取制造流程主导入模板",
    dependencies=[Depends(AuthPermission(["module_make:blanking:download"]))]
)
async def export_blanking_template_controller() -> StreamingResponse:
    """
    获取制造流程主导入模板接口
    
    返回:
    - StreamingResponse - 包含制造流程主导入模板的流式响应
    """
    import_template_result = await ProduceMakeService.import_template_download_blanking_service()
    log.info('获取制造流程主导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_make_template.xlsx'}
    )