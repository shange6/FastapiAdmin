# -*- coding: utf-8 -*-

import io
import pandas as pd
from fastapi import UploadFile
from sqlalchemy import select, text

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_schema import BatchSetAvailable
from app.core.exceptions import CustomException
from app.core.logger import log
from app.utils.excel_util import ExcelUtil
from app.core.database import async_db_session

from .crud import ProduceBomRouteCRUD
from .schema import (
    ProduceBomRouteCreateSchema,
    ProduceBomRouteUpdateSchema,
    ProduceBomRouteOutSchema,
    ProduceBomRouteQueryParam,
    ProduceBomRouteOutSchema,
)


class ProduceBomRouteService:
    """
    BOM路线关联服务层
    """
    
    @classmethod
    async def detail_bomroute_service(cls, auth: AuthSchema, id: int) -> dict:
        """
        详情
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        
        返回:
        - dict - 数据详情
        """
        obj = await ProduceBomRouteCRUD(auth).get_by_id_bomroute_crud(id=id)
        if not obj:
            raise CustomException(msg="该数据不存在")
        return ProduceBomRouteOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def summary_missing_routes_by_project_service(cls, auth: AuthSchema, project_code: str) -> dict:
        """
        按项目统计未配置路线的BOM数量，按第一层级BOM分组
        
        参数:
        - auth: AuthSchema - 认证信息
        - project_code: str - 项目代号
        
        返回:
        - dict - {root_bom_code: count}
        """
        from sqlalchemy import text
        # 逻辑：
        # 1. 找到该项目下所有的第一层级BOM (parent_code = project_code)
        # 2. 统计这些第一层级BOM及其所有后代 (first_code = root_code) 中不在 produce_bom_route 的记录
        sql = text("""
            SELECT b1.code, COUNT(b2.id) as cnt
            FROM data_bom b1
            JOIN data_bom b2 ON b2.first_code = b1.code
            LEFT JOIN produce_bom_route r ON r.bom_id = b2.id
            WHERE b1.parent_code = :project_code AND r.bom_id IS NULL
            GROUP BY b1.code
        """)
        res = await auth.db.execute(sql, {"project_code": project_code})
        return {row[0]: row[1] for row in res.fetchall()}

    @classmethod
    async def summary_all_projects_missing_routes_service(cls, auth: AuthSchema) -> dict:
        """
        统计所有项目下未配置路线的BOM总数

        返回:
        - dict - {project_code: total_missing_count}
        """
        from sqlalchemy import text
        sql = text("""
            SELECT b.parent_code, COUNT(b.id) as cnt
            FROM data_bom b
            LEFT JOIN produce_bom_route r ON r.bom_id = b.id
            WHERE r.bom_id IS NULL
            GROUP BY b.parent_code
        """)
        res = await auth.db.execute(sql)
        return {row[0]: row[1] for row in res.fetchall()}

    @classmethod
    async def summary_missing_routes_count_by_project_id_service(cls, auth: AuthSchema, project_id: int) -> dict:
        """
        根据项目ID统计缺失路线数量
        逻辑：
        1. 统计 produce_bom_route 中 project_id = 当前项目ID 的记录数
        2. 统计该项目下所有BOM后代的总数 (通过 data_bom 的 parent_code 递归获取)
        3. 返回 差额 = 后代总数 - 已配置数

        参数:
        - auth: AuthSchema - 认证信息
        - project_id: int - 项目ID

        返回:
        - dict - {project_id: missing_count}
        """
        from sqlalchemy import text
        from app.core.database import async_db_session
        from app.core.logger import log

        async with async_db_session() as session:
            # 1. 获取项目 code
            proj_sql = text("SELECT code FROM data_project WHERE id = :project_id")
            proj_result = await session.execute(proj_sql, {"project_id": project_id})
            project_row = proj_result.fetchone()
            if not project_row:
                return {"project_id": project_id, "missing_count": 0}

            project_code = project_row[0]
            log.info(f"[getMissingRouteProjectList] 项目ID: {project_id}, 项目code: {project_code}")

            # 2. 统计 produce_bom_route 中该项目已配置的路线数量
            route_count_sql = text("SELECT COUNT(*) FROM produce_bom_route WHERE project_id = :project_id")
            route_result = await session.execute(route_count_sql, {"project_id": project_id})
            configured_count = route_result.scalar() or 0
            log.info(f"[getMissingRouteProjectList] 已配置路线数量 (configured_count): {configured_count}")
            log.info(f"[getMissingRouteProjectList] SQL: {route_count_sql}; params: {{project_id: {project_id}}}")

            # 3. 递归统计该项目下所有 BOM 后代数量
            # 直接统计 first_code 属于该项目根节点的所有 BOM 数量（排除外购件 procure = 1）
            total_sql = text("""
                SELECT COUNT(*) FROM data_bom
                WHERE first_code IN (
                    SELECT code FROM data_bom WHERE parent_code = :project_code
                ) AND procure = 0
            """)
            total_result = await session.execute(total_sql, {"project_code": project_code})
            total_count = total_result.scalar() or 0
            log.info(f"[getMissingRouteProjectList] BOM后代总数 (total_count, 排除外购): {total_count}")
            log.info(f"[getMissingRouteProjectList] SQL: {total_sql}; params: {{project_code: {project_code}}}")

            missing_count = total_count - configured_count
            log.info(f"[getMissingRouteProjectList] 差额计算: {total_count} - {configured_count} = {missing_count}")
            return {"project_id": project_id, "missing_count": max(0, missing_count)}

    @classmethod
    async def summary_missing_routes_count_by_first_id_service(cls, auth: AuthSchema, first_id: int) -> dict:
        """
        根据 first_id（点击的 BOM 的 ID）统计缺失路线数量
        逻辑：
        1. 获取该 first_id 对应的 BOM 信息
        2. 统计 produce_bom_route 中 first_id = 当前ID 的记录数（已配置数量）
        3. 统计该 BOM 所属项目下所有 BOM 数量（通过 project_code 匹配）
        4. 返回 差额 = 总数 - 已配置数

        参数:
        - auth: AuthSchema - 认证信息
        - first_id: int - 点击的 BOM 的 ID

        返回:
        - dict - {first_id: missing_count}
        """
        from sqlalchemy import text
        from app.core.database import async_db_session
        from app.core.logger import log

        async with async_db_session() as session:
            # 1. 获取该 first_id 对应的 BOM 的 project_code
            bom_sql = text("SELECT project_code, code FROM data_bom WHERE id = :first_id")
            bom_result = await session.execute(bom_sql, {"first_id": first_id})
            bom_row = bom_result.fetchone()
            if not bom_row:
                return {"first_id": first_id, "missing_count": 0}

            project_code = bom_row[0]
            bom_code = bom_row[1]
            log.info(f"[getMissingRouteBomPreview] BOM ID: {first_id}, 项目code: {project_code}, BOM code: {bom_code}")

            # 2. 统计 produce_bom_route 中该 first_id 已配置的路线数量
            route_count_sql = text("SELECT COUNT(*) FROM produce_bom_route WHERE first_id = :first_id")
            route_result = await session.execute(route_count_sql, {"first_id": first_id})
            configured_count = route_result.scalar() or 0
            log.info(f"[getMissingRouteBomPreview] 已配置路线数量 (configured_count): {configured_count}")
            log.info(f"[getMissingRouteBomPreview] SQL: SELECT COUNT(*) FROM produce_bom_route WHERE first_id = {first_id}")

            # 3. 统计该项目下所有 BOM 数量（通过 project_code 匹配，排除外购件 procure = 1）
            total_sql = text("""
                SELECT COUNT(*) FROM data_bom 
                WHERE project_code = :project_code AND procure = 0
            """)
            total_result = await session.execute(total_sql, {"project_code": project_code})
            total_count = total_result.scalar() or 0
            log.info(f"[getMissingRouteBomPreview] 项目下BOM总数 (total_count, 排除外购): {total_count}")
            log.info(f"[getMissingRouteBomPreview] SQL: SELECT COUNT(*) FROM data_bom WHERE project_code = '{project_code}' AND procure = 0")

            missing_count = total_count - configured_count
            log.info(f"[getMissingRouteBomPreview] 差额计算: {total_count} - {configured_count} = {missing_count}")
            return {"first_id": first_id, "missing_count": max(0, missing_count)}

    @classmethod
    async def list_bomroute_service(cls, auth: AuthSchema, search: ProduceBomRouteQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询

        参数:
        - auth: AuthSchema - 认证信息
        - search: ProduceBomRouteQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数

        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await ProduceBomRouteCRUD(auth).list_bomroute_crud(search=search_dict, order_by=order_by)
        return [ProduceBomRouteOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def list_all_bomroute_service(cls, auth: AuthSchema) -> list[dict]:
        """
        查询全部BOM路线关联（不分页，用于下拉选项等场景）

        参数:
        - auth: AuthSchema - 认证信息

        返回:
        - list[dict] - BOM路线关联列表
        """
        async with async_db_session() as session:
            sql = text("SELECT bom_id, `route` FROM produce_bom_route")
            result = await session.execute(sql)
            rows = result.fetchall()
            return [{"bom_id": row[0], "route": row[1]} for row in rows]

    @classmethod
    async def page_bomroute_service(cls, auth: AuthSchema, page_no: int, page_size: int, search: ProduceBomRouteQueryParam | None = None, order_by: list[dict] | None = None) -> dict:
        """
        分页查询（数据库分页）
        
        参数:
        - auth: AuthSchema - 认证信息
        - page_no: int - 页码
        - page_size: int - 每页数量
        - search: ProduceBomRouteQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - dict - 分页查询结果
        """
        search_dict = search.__dict__ if search else {}
        order_by_list = order_by or [{'id': 'asc'}]
        offset = (page_no - 1) * page_size
        result = await ProduceBomRouteCRUD(auth).page_bomroute_crud(
            offset=offset,
            limit=page_size,
            order_by=order_by_list,
            search=search_dict
        )
        return result
    
    @classmethod
    async def create_bomroute_service(cls, auth: AuthSchema, data: ProduceBomRouteCreateSchema) -> dict:
        """
        创建
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: ProduceBomRouteCreateSchema - 创建数据
        
        返回:
        - dict - 创建结果
        """
        obj = await ProduceBomRouteCRUD(auth).create_bomroute_crud(data=data)
        return ProduceBomRouteOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def upsert_bomroute_service(cls, auth: AuthSchema, bom_id: int, route: int) -> dict:
        """
        插入或更新BOM路线关联（如果bom_id已存在则更新，不存在则创建）

        参数:
        - auth: AuthSchema - 认证信息
        - bom_id: int - BOM ID
        - route: int - 工艺路线

        返回:
        - dict - 结果
        """
        existing = await ProduceBomRouteCRUD(auth).get_by_bom_id_crud(bom_id=bom_id)
        async with async_db_session() as session:
            if existing:
                sql = text("UPDATE produce_bom_route SET `route` = :route WHERE bom_id = :bom_id")
                await session.execute(sql, {"route": route, "bom_id": bom_id})
                await session.commit()
            else:
                sql = text("INSERT INTO produce_bom_route (bom_id, `route`) VALUES (:bom_id, :route)")
                await session.execute(sql, {"bom_id": bom_id, "route": route})
                await session.commit()
            return {"bom_id": bom_id, "route": route}

    @classmethod
    async def upsert_batch_bomroute_service(cls, auth: AuthSchema, data: list) -> dict:
        """
        批量插入或更新BOM路线关联（合并为单条SQL执行）

        参数:
        - auth: AuthSchema - 认证信息
        - data: list - BOM路线关联列表，每项包含 bom_id、route、project_id 和 first_id

        返回:
        - dict - 结果
        """
        if not data:
            return {"insert": 0, "update": 0, "skip": 0}
        async with async_db_session() as session:
            bom_ids = [item["bom_id"] for item in data]
            placeholders = ",".join([f":id{i}" for i in range(len(bom_ids))])
            params = {f"id{i}": bid for i, bid in enumerate(bom_ids)}
            sql = text(f"SELECT bom_id, `route`, project_id, first_id FROM produce_bom_route WHERE bom_id IN ({placeholders})")
            result = await session.execute(sql, params)
            existing = {row[0]: {"route": row[1], "project_id": row[2], "first_id": row[3]} for row in result.fetchall()}
            to_insert = []
            to_update = []
            for item in data:
                bom_id = item["bom_id"]
                route = item["route"]
                project_id = item.get("project_id")
                first_id = item.get("first_id")
                if bom_id not in existing:
                    to_insert.append({"bom_id": bom_id, "route": route, "project_id": project_id, "first_id": first_id})
                elif existing[bom_id]["route"] != route:
                    to_update.append({"bom_id": bom_id, "route": route, "project_id": project_id, "first_id": first_id})
            if to_insert:
                ins_sql = text("INSERT INTO produce_bom_route (bom_id, `route`, project_id, first_id) VALUES (:bom_id, :route, :project_id, :first_id)")
                await session.execute(ins_sql, to_insert)
            if to_update:
                upd_sql = text("UPDATE produce_bom_route SET `route` = :route, project_id = :project_id, first_id = :first_id WHERE bom_id = :bom_id")
                await session.execute(upd_sql, to_update)
            if to_insert or to_update:
                await session.commit()
            return {"insert": len(to_insert), "update": len(to_update), "skip": len(data) - len(to_insert) - len(to_update)}

    @classmethod
    async def update_bomroute_service(cls, auth: AuthSchema, id: int, data: ProduceBomRouteUpdateSchema) -> dict:
        """
        更新
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        - data: ProduceBomRouteUpdateSchema - 更新数据
        
        返回:
        - dict - 更新结果
        """
        # 检查数据是否存在
        obj = await ProduceBomRouteCRUD(auth).get_by_id_bomroute_crud(id=id)
        if not obj:
            raise CustomException(msg='更新失败，该数据不存在')
        
        # 检查唯一性约束
            
        obj = await ProduceBomRouteCRUD(auth).update_bomroute_crud(id=id, data=data)
        return ProduceBomRouteOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def delete_bomroute_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        删除
        
        参数:
        - auth: AuthSchema - 认证信息
        - ids: list[int] - 数据ID列表
        
        返回:
        - None
        """
        if len(ids) < 1:
            raise CustomException(msg='删除失败，删除对象不能为空')
        for id in ids:
            obj = await ProduceBomRouteCRUD(auth).get_by_id_bomroute_crud(id=id)
            if not obj:
                raise CustomException(msg=f'删除失败，ID为{id}的数据不存在')
        await ProduceBomRouteCRUD(auth).delete_bomroute_crud(ids=ids)
    
    @classmethod
    async def set_available_bomroute_service(cls, auth: AuthSchema, data: BatchSetAvailable) -> None:
        """
        批量设置状态
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: BatchSetAvailable - 批量设置状态数据
        
        返回:
        - None
        """
        await ProduceBomRouteCRUD(auth).set_available_bomroute_crud(ids=data.ids, status=data.status)
    
    @classmethod
    async def batch_export_bomroute_service(cls, obj_list: list[dict]) -> bytes:
        """
        批量导出
        
        参数:
        - obj_list: list[dict] - 数据列表
        
        返回:
        - bytes - 导出的Excel文件内容
        """
        mapping_dict = {
            'bom_id': 'BOMID',
            'route': '工艺路线',
        }
        # 复制数据并转换状态
        data = obj_list.copy()
        for item in data:
            # 处理状态
            item["status"] = "启用" if item.get("status") == "0" else "停用"
            # 处理创建者
            creator_info = item.get("created_id")
            if isinstance(creator_info, dict):
                item["created_id"] = creator_info.get("name", "未知")
            else:
                item["created_id"] = "未知"

        return ExcelUtil.export_list2excel(list_data=data, mapping_dict=mapping_dict)

    @classmethod
    async def batch_import_bomroute_service(cls, auth: AuthSchema, file: UploadFile, update_support: bool = False) -> str:
        """
        批量导入
        
        参数:
        - auth: AuthSchema - 认证信息
        - file: UploadFile - 上传的Excel文件
        - update_support: bool - 是否支持更新存在数据
        
        返回:
        - str - 导入结果信息
        """
        header_dict = {
            'BOMID': 'bom_id',
            '工艺路线': 'route',
        }

        try:
            # 读取Excel文件
            contents = await file.read()
            df = pd.read_excel(io.BytesIO(contents))
            await file.close()

            if df.empty:
                raise CustomException(msg="导入文件为空")

            # 检查表头是否完整
            missing_headers = [header for header in header_dict.keys() if header not in df.columns]
            if missing_headers:
                raise CustomException(msg=f"导入文件缺少必要的列: {', '.join(missing_headers)}")

            # 重命名列名
            df.rename(columns=header_dict, inplace=True)
            
            # 验证必填字段
            
            error_msgs = []
            success_count = 0
            count = 0
            
            for _index, row in df.iterrows():
                count += 1
                try:
                    data = {
                        "bom_id": row['bom_id'],
                        "route": row['route'],
                    }
                    # 使用CreateSchema做校验后入库
                    create_schema = ProduceBomRouteCreateSchema.model_validate(data)
                    
                    # 检查唯一性约束
                    
                    await ProduceBomRouteCRUD(auth).create_bomroute_crud(data=create_schema)
                    success_count += 1
                except Exception as e:
                    error_msgs.append(f"第{count}行: {str(e)}")
                    continue

            result = f"成功导入 {success_count} 条数据"
            if error_msgs:
                result += "\n错误信息:\n" + "\n".join(error_msgs)
            return result
            
        except Exception as e:
            log.error(f"批量导入失败: {str(e)}")
            raise CustomException(msg=f"导入失败: {str(e)}")
    
    @classmethod
    async def import_template_download_bomroute_service(cls) -> bytes:
        """
        下载导入模板
        
        返回:
        - bytes - Excel文件的二进制数据
        """
        header_list = [
            'BOMID',
            '工艺路线',
        ]
        selector_header_list = []
        option_list = []
        
        
        return ExcelUtil.get_excel_template(
            header_list=header_list,
            selector_header_list=selector_header_list,
            option_list=option_list
        )