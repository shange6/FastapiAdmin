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

from .service import ProduceBomRouteService
from .schema import ProduceBomRouteCreateSchema, ProduceBomRouteUpdateSchema, ProduceBomRouteQueryParam

ProduceBomRouteRouter = APIRouter(prefix='/bomroute', tags=["BOM路线关联模块"]) 

@ProduceBomRouteRouter.get(
    "/summary/missing/all",
    summary="统计所有项目缺失路线数量",
    description="统计所有项目下未配置路线的BOM总数"
)
async def summary_all_projects_missing_routes_controller(
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    统计所有项目缺失路线数量接口
    
    返回:
    - JSONResponse - 统计结果字典
    """
    result = await ProduceBomRouteService.summary_all_projects_missing_routes_service(auth=auth)
    return SuccessResponse(data=result, msg="查询成功")


@ProduceBomRouteRouter.get(
    "/summary/missing/{project_code}",
    summary="按项目统计未配置路线的BOM数量",
    description="按项目代号统计未配置路线的BOM数量，按第一层级BOM分组"
)
async def summary_missing_routes_by_project_controller(
    project_code: str = Path(..., description="项目代号"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    按项目统计未配置路线的BOM数量接口

    参数:
    - project_code: str - 项目代号
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含统计结果的JSON响应
    """
    result = await ProduceBomRouteService.summary_missing_routes_by_project_service(auth=auth, project_code=project_code)
    return SuccessResponse(data=result, msg="查询成功")

@ProduceBomRouteRouter.get(
    "/summary/missing/count/by-project-id/{project_id}",
    summary="根据项目ID统计缺失路线数量",
    description="根据项目ID统计缺失路线数量，返回差额"
)
async def summary_missing_routes_count_by_project_id_controller(
    project_id: int = Path(..., description="项目ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    根据项目ID统计缺失路线数量接口

    参数:
    - project_id: int - 项目ID
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含统计结果的JSON响应
    """
    result = await ProduceBomRouteService.summary_missing_routes_count_by_project_id_service(auth=auth, project_id=project_id)
    return SuccessResponse(data=result, msg="查询成功")

@ProduceBomRouteRouter.get(
    "/summary/missing/count/by-first-id/{first_id}",
    summary="根据first_id统计缺失路线数量",
    description="根据点击的BOM的ID统计缺失路线数量，返回差额"
)
async def summary_missing_routes_count_by_first_id_controller(
    first_id: int = Path(..., description="BOM ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    根据first_id统计缺失路线数量接口

    参数:
    - first_id: int - BOM ID
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含统计结果的JSON响应
    """
    result = await ProduceBomRouteService.summary_missing_routes_count_by_first_id_service(auth=auth, first_id=first_id)
    return SuccessResponse(data=result, msg="查询成功")


@ProduceBomRouteRouter.get(
    "/detail/{id}",
    summary="获取BOM路线关联详情",
    description="获取BOM路线关联详情"
)
async def get_bomroute_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    获取BOM路线关联详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含BOM路线关联详情的JSON响应
    """
    result_dict = await ProduceBomRouteService.detail_bomroute_service(auth=auth, id=id)
    log.info(f"获取BOM路线关联详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取BOM路线关联详情成功")

@ProduceBomRouteRouter.get(
    "/list",
    summary="查询BOM路线关联列表",
    description="查询BOM路线关联列表"
)
async def get_bomroute_list_controller(
    page: PaginationQueryParam = Depends(),
    search: ProduceBomRouteQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    查询BOM路线关联列表接口（数据库分页）

    参数:
    - page: PaginationQueryParam - 分页参数
    - search: ProduceBomRouteQueryParam - 查询参数
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含BOM路线关联列表的JSON响应
    """
    result_dict = await ProduceBomRouteService.page_bomroute_service(
        auth=auth,
        page_no=page.page_no if page.page_no is not None else 1,
        page_size=page.page_size if page.page_size is not None else 10,
        search=search,
        order_by=page.order_by
    )
    log.info("查询BOM路线关联列表成功")
    return SuccessResponse(data=result_dict, msg="查询BOM路线关联列表成功")

@ProduceBomRouteRouter.get(
    "/list/all",
    summary="获取全部BOM路线关联",
    description="获取全部BOM路线关联，不分页"
)
async def get_bomroute_all_controller(
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:query"]))
) -> JSONResponse:
    """
    获取全部BOM路线关联接口（不分页）

    参数:
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含全部BOM路线关联的JSON响应
    """
    result_list = await ProduceBomRouteService.list_all_bomroute_service(auth=auth)
    log.info(f"获取全部BOM路线关联成功，共 {len(result_list)} 条")
    return SuccessResponse(data=result_list, msg="获取全部BOM路线关联成功")

@ProduceBomRouteRouter.post(
    "/create",
    summary="创建BOM路线关联",
    description="创建BOM路线关联"
)
async def create_bomroute_controller(
    data: ProduceBomRouteCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:create"]))
) -> JSONResponse:
    """
    创建BOM路线关联接口
    
    参数:
    - data: ProduceBomRouteCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建BOM路线关联结果的JSON响应
    """
    result_dict = await ProduceBomRouteService.create_bomroute_service(auth=auth, data=data)
    log.info("创建BOM路线关联成功")
    return SuccessResponse(data=result_dict, msg="创建BOM路线关联成功")

@ProduceBomRouteRouter.post(
    "/upsert",
    summary="插入或更新BOM路线关联",
    description="如果bom_id已存在则更新，不存在则创建"
)
async def upsert_bomroute_controller(
    bom_id: int = Body(..., description="BOM ID"),
    route: int = Body(..., description="工艺路线"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:create"]))
) -> JSONResponse:
    """
    插入或更新BOM路线关联接口

    参数:
    - bom_id: int - BOM ID
    - route: int - 工艺路线
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含结果的JSON响应
    """
    result_dict = await ProduceBomRouteService.upsert_bomroute_service(auth=auth, bom_id=bom_id, route=route)
    log.info(f"Upsert BOM路线关联成功: bom_id={bom_id}, route={route}")
    return SuccessResponse(data=result_dict, msg="保存成功")

@ProduceBomRouteRouter.post(
    "/upsert/batch",
    summary="批量插入或更新BOM路线关联",
    description="如果bom_id已存在则更新，不存在则创建，合并为单条SQL执行"
)
async def upsert_batch_bomroute_controller(
    data: list = Body(..., description="BOM路线关联列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:create"]))
) -> JSONResponse:
    """
    批量插入或更新BOM路线关联接口

    参数:
    - data: list - BOM路线关联列表，每项包含 bom_id 和 route
    - auth: AuthSchema - 认证信息

    返回:
    - JSONResponse - 包含结果的JSON响应
    """
    result = await ProduceBomRouteService.upsert_batch_bomroute_service(auth=auth, data=data)
    log.info(f"批量Upsert BOM路线关联成功: {len(data)} 条")
    return SuccessResponse(data=result, msg=f"新增：{result['insert']}，更新：{result['update']}")

@ProduceBomRouteRouter.put(
    "/update/{id}",
    summary="修改BOM路线关联",
    description="修改BOM路线关联"
)
async def update_bomroute_controller(
    data: ProduceBomRouteUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:update"]))
) -> JSONResponse:
    """
    修改BOM路线关联接口
    
    参数:
    - id: int - 数据ID
    - data: ProduceBomRouteUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改BOM路线关联结果的JSON响应
    """
    result_dict = await ProduceBomRouteService.update_bomroute_service(auth=auth, id=id, data=data)
    log.info("修改BOM路线关联成功")
    return SuccessResponse(data=result_dict, msg="修改BOM路线关联成功")

@ProduceBomRouteRouter.delete(
    "/delete",
    summary="删除BOM路线关联",
    description="删除BOM路线关联"
)
async def delete_bomroute_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:delete"]))
) -> JSONResponse:
    """
    删除BOM路线关联接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除BOM路线关联结果的JSON响应
    """
    await ProduceBomRouteService.delete_bomroute_service(auth=auth, ids=ids)
    log.info(f"删除BOM路线关联成功: {ids}")
    return SuccessResponse(msg="删除BOM路线关联成功")

@ProduceBomRouteRouter.patch(
    "/available/setting",
    summary="批量修改BOM路线关联状态",
    description="批量修改BOM路线关联状态"
)
async def batch_set_available_bomroute_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:patch"]))
) -> JSONResponse:
    """
    批量修改BOM路线关联状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改BOM路线关联状态结果的JSON响应
    """
    await ProduceBomRouteService.set_available_bomroute_service(auth=auth, data=data)
    log.info(f"批量修改BOM路线关联状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改BOM路线关联状态成功")

@ProduceBomRouteRouter.post(
    '/export',
    summary="导出BOM路线关联",
    description="导出BOM路线关联"
)
async def export_bomroute_list_controller(
    search: ProduceBomRouteQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:export"]))
) -> StreamingResponse:
    """
    导出BOM路线关联接口
    
    参数:
    - search: ProduceBomRouteQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出BOM路线关联数据的流式响应
    """
    result_dict_list = await ProduceBomRouteService.list_bomroute_service(search=search, auth=auth)
    export_result = await ProduceBomRouteService.batch_export_bomroute_service(obj_list=result_dict_list)
    log.info('导出BOM路线关联成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_bom_route.xlsx'}
    )

@ProduceBomRouteRouter.post(
    '/import',
    summary="导入BOM路线关联",
    description="导入BOM路线关联"
)
async def import_bomroute_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_produce:bomroute:import"]))
) -> JSONResponse:
    """
    导入BOM路线关联接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入BOM路线关联结果的JSON响应
    """
    batch_import_result = await ProduceBomRouteService.batch_import_bomroute_service(file=file, auth=auth, update_support=True)
    log.info("导入BOM路线关联成功")
    return SuccessResponse(data=batch_import_result, msg="导入BOM路线关联成功")

@ProduceBomRouteRouter.post(
    '/download/template',
    summary="获取BOM路线关联导入模板",
    description="获取BOM路线关联导入模板",
    dependencies=[Depends(AuthPermission(["module_produce:bomroute:download"]))]
)
async def export_bomroute_template_controller() -> StreamingResponse:
    """
    获取BOM路线关联导入模板接口
    
    返回:
    - StreamingResponse - 包含BOM路线关联导入模板的流式响应
    """
    import_template_result = await ProduceBomRouteService.import_template_download_bomroute_service()
    log.info('获取BOM路线关联导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=produce_bom_route_template.xlsx'}
    )