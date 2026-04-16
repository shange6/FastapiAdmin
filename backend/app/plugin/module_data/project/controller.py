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

from .service import DataProjectService
from .schema import DataProjectCreateSchema, DataProjectUpdateSchema, DataProjectQueryParam

DataProjectRouter = APIRouter(prefix='/project', tags=["项目信息模块"]) 

@DataProjectRouter.get(
    "/detail/{id}",
    summary="获取项目信息详情",
    description="获取项目信息详情"
)
async def get_project_detail_controller(
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:query"]))
) -> JSONResponse:
    """
    获取项目信息详情接口
    
    参数:
    - id: int - 数据ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含项目信息详情的JSON响应
    """
    result_dict = await DataProjectService.detail_project_service(auth=auth, id=id)
    log.info(f"获取项目信息详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取项目信息详情成功")

@DataProjectRouter.get(
    "/list/all",
    summary="查询所有项目信息列表",
    description="查询所有项目信息列表（不分页）"
)
async def get_project_all_list_controller(
    show_dai: int | None = Query(None, description="指定工艺ID，统计该工艺下的待办数量"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:query"]))
) -> JSONResponse:
    """
    查询所有项目信息列表接口（不分页）
    
    参数:
    - show_dai: int | None - 指定工艺ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含项目信息列表的JSON响应
    """
    result_list = await DataProjectService.list_project_service(auth=auth, show_dai=show_dai)
    log.info("查询所有项目信息列表成功")
    return SuccessResponse(data=result_list, msg="查询所有项目信息列表成功")

@DataProjectRouter.get(
    "/list",
    summary="查询项目信息列表",
    description="查询项目信息列表"
)
async def get_project_list_controller(
    page: PaginationQueryParam = Depends(),
    search: DataProjectQueryParam = Depends(),
    show_dai: int | None = Query(None, description="指定工艺ID，统计该工艺下的待办数量"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:query"]))
) -> JSONResponse:
    """
    查询项目信息列表接口（数据库分页）
    
    参数:
    - page: PaginationQueryParam - 分页参数
    - search: DataProjectQueryParam - 查询参数
    - show_dai: int | None - 指定工艺ID
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含项目信息列表的JSON响应
    """
    result_dict = await DataProjectService.page_project_service(
        auth=auth,
        page_no=page.page_no if page.page_no is not None else 1,
        page_size=page.page_size if page.page_size is not None else 10,
        search=search,
        order_by=page.order_by,
        show_dai=show_dai
    )
    log.info("查询项目信息列表成功")
    return SuccessResponse(data=result_dict, msg="查询项目信息列表成功")

@DataProjectRouter.post(
    "/create",
    summary="创建项目信息",
    description="创建项目信息"
)
async def create_project_controller(
    data: DataProjectCreateSchema,
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:create"]))
) -> JSONResponse:
    """
    创建项目信息接口
    
    参数:
    - data: DataProjectCreateSchema - 创建数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含创建项目信息结果的JSON响应
    """
    result_dict = await DataProjectService.create_project_service(auth=auth, data=data)
    log.info("创建项目信息成功")
    return SuccessResponse(data=result_dict, msg="创建项目信息成功")

@DataProjectRouter.put(
    "/update/{id}",
    summary="修改项目信息",
    description="修改项目信息"
)
async def update_project_controller(
    data: DataProjectUpdateSchema,
    id: int = Path(..., description="ID"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:update"]))
) -> JSONResponse:
    """
    修改项目信息接口
    
    参数:
    - id: int - 数据ID
    - data: DataProjectUpdateSchema - 更新数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含修改项目信息结果的JSON响应
    """
    result_dict = await DataProjectService.update_project_service(auth=auth, id=id, data=data)
    log.info("修改项目信息成功")
    return SuccessResponse(data=result_dict, msg="修改项目信息成功")

@DataProjectRouter.delete(
    "/delete",
    summary="删除项目信息",
    description="删除项目信息"
)
async def delete_project_controller(
    ids: list[int] = Body(..., description="ID列表"),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:delete"]))
) -> JSONResponse:
    """
    删除项目信息接口
    
    参数:
    - ids: list[int] - 数据ID列表
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含删除项目信息结果的JSON响应
    """
    await DataProjectService.delete_project_service(auth=auth, ids=ids)
    log.info(f"删除项目信息成功: {ids}")
    return SuccessResponse(msg="删除项目信息成功")

@DataProjectRouter.patch(
    "/available/setting",
    summary="批量修改项目信息状态",
    description="批量修改项目信息状态"
)
async def batch_set_available_project_controller(
    data: BatchSetAvailable,
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:patch"]))
) -> JSONResponse:
    """
    批量修改项目信息状态接口
    
    参数:
    - data: BatchSetAvailable - 批量修改状态数据
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含批量修改项目信息状态结果的JSON响应
    """
    await DataProjectService.set_available_project_service(auth=auth, data=data)
    log.info(f"批量修改项目信息状态成功: {data.ids}")
    return SuccessResponse(msg="批量修改项目信息状态成功")

@DataProjectRouter.post(
    '/export',
    summary="导出项目信息",
    description="导出项目信息"
)
async def export_project_list_controller(
    search: DataProjectQueryParam = Depends(),
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:export"]))
) -> StreamingResponse:
    """
    导出项目信息接口
    
    参数:
    - search: DataProjectQueryParam - 查询参数
    - auth: AuthSchema - 认证信息
    
    返回:
    - StreamingResponse - 包含导出项目信息数据的流式响应
    """
    result_dict_list = await DataProjectService.list_project_service(search=search, auth=auth)
    export_result = await DataProjectService.batch_export_project_service(obj_list=result_dict_list)
    log.info('导出项目信息成功')
    return StreamResponse(
        data=bytes2file_response(export_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=data_project.xlsx'}
    )

@DataProjectRouter.post(
    '/import',
    summary="导入项目信息",
    description="导入项目信息"
)
async def import_project_list_controller(
    file: UploadFile,
    auth: AuthSchema = Depends(AuthPermission(["module_data:project:import"]))
) -> JSONResponse:
    """
    导入项目信息接口
    
    参数:
    - file: UploadFile - 上传的Excel文件
    - auth: AuthSchema - 认证信息
    
    返回:
    - JSONResponse - 包含导入项目信息结果的JSON响应
    """
    batch_import_result = await DataProjectService.batch_import_project_service(file=file, auth=auth, update_support=True)
    log.info("导入项目信息成功")
    return SuccessResponse(data=batch_import_result, msg="导入项目信息成功")

@DataProjectRouter.post(
    '/download/template',
    summary="获取项目信息导入模板",
    description="获取项目信息导入模板",
    dependencies=[Depends(AuthPermission(["module_data:project:download"]))]
)
async def export_project_template_controller() -> StreamingResponse:
    """
    获取项目信息导入模板接口
    
    返回:
    - StreamingResponse - 包含项目信息导入模板的流式响应
    """
    import_template_result = await DataProjectService.import_template_download_project_service()
    log.info('获取项目信息导入模板成功')
    return StreamResponse(
        data=bytes2file_response(import_template_result),
        media_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        headers={'Content-Disposition': 'attachment; filename=data_project_template.xlsx'}
    )