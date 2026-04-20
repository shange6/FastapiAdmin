# -*- coding: utf-8 -*-

import io
import pandas as pd
from fastapi import UploadFile
from sqlalchemy import func, select

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_schema import BatchSetAvailable
from app.core.exceptions import CustomException
from app.core.logger import log
from app.utils.excel_util import ExcelUtil

from .crud import ProduceBomManhourCRUD
from .model import ProduceBomManhourModel
from ..craft.model import ProduceCraftModel
from ..order.model import ProduceOrderModel
from ...module_data.bom.model import DataBomModel
from ...module_data.project.model import DataProjectModel
from .schema import (
    ProduceBomManhourCreateSchema,
    ProduceBomManhourUpdateSchema,
    ProduceBomManhourOutSchema,
    ProduceBomManhourQueryParam,
    ProduceBomManhourUpsertBatchSchema,
    ProduceBatchProjectIdSchema,
)


class ProduceBomManhourService:
    """
    BOM工时关联服务层
    """
    
    @classmethod
    async def detail_bommanhour_service(cls, auth: AuthSchema, id: int) -> dict:
        """
        详情
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        
        返回:
        - dict - 数据详情
        """
        obj = await ProduceBomManhourCRUD(auth).get_by_id_bommanhour_crud(id=id)
        if not obj:
            raise CustomException(msg="该数据不存在")
        return ProduceBomManhourOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def list_bommanhour_service(cls, auth: AuthSchema, search: ProduceBomManhourQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询
        
        参数:
        - auth: AuthSchema - 认证信息
        - search: ProduceBomManhourQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await ProduceBomManhourCRUD(auth).list_bommanhour_crud(search=search_dict, order_by=order_by)
        return [ProduceBomManhourOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def page_bommanhour_service(cls, auth: AuthSchema, page_no: int, page_size: int, search: ProduceBomManhourQueryParam | None = None, order_by: list[dict] | None = None) -> dict:
        """
        分页查询（数据库分页）
        
        参数:
        - auth: AuthSchema - 认证信息
        - page_no: int - 页码
        - page_size: int - 每页数量
        - search: ProduceBomManhourQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - dict - 分页查询结果
        """
        search_dict = search.__dict__ if search else {}
        order_by_list = order_by or [{'id': 'asc'}]
        offset = (page_no - 1) * page_size
        result = await ProduceBomManhourCRUD(auth).page_bommanhour_crud(
            offset=offset,
            limit=page_size,
            order_by=order_by_list,
            search=search_dict
        )
        return result
    
    @classmethod
    async def create_bommanhour_service(cls, auth: AuthSchema, data: ProduceBomManhourCreateSchema) -> dict:
        """
        创建
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: ProduceBomManhourCreateSchema - 创建数据
        
        返回:
        - dict - 创建结果
        """
        obj = await ProduceBomManhourCRUD(auth).create_bommanhour_crud(data=data)
        return ProduceBomManhourOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def upsert_batch_bommanhour_service(cls, auth: AuthSchema, payload: ProduceBomManhourUpsertBatchSchema) -> dict:
        items = payload.items or []
        if not items:
            return {"inserted": 0, "updated": 0, "deleted": 0}

        inserted = 0
        updated = 0
        deleted = 0
        crud = ProduceBomManhourCRUD(auth)

        # 获取所有涉及的 bom_id 的 project_code 和 first_code
        bom_ids = list(set([item.bom_id for item in items]))
        bom_sql = select(DataBomModel.id, DataBomModel.project_code, DataBomModel.first_code).where(DataBomModel.id.in_(bom_ids))
        bom_res = await auth.db.execute(bom_sql)
        bom_info_map = {row.id: (row.project_code, row.first_code) for row in bom_res.all()}

        for item in items:
            # 优先从 data_bom 获取编码，确保一致性
            bom_info = bom_info_map.get(item.bom_id)
            project_code = bom_info[0] if bom_info else item.project_code
            first_code = bom_info[1] if bom_info else item.first_code

            sql = select(ProduceBomManhourModel).where(
                ProduceBomManhourModel.bom_id == item.bom_id,
                ProduceBomManhourModel.craft_id == item.craft_id,
            )
            result = await auth.db.execute(sql)
            existed = result.scalars().first()
            if item.manhour <= 0:
                if existed:
                    await crud.delete_bommanhour_crud(ids=[int(existed.id)])  # type: ignore[arg-type]
                    deleted += 1
                continue

            if existed:
                await crud.update_bommanhour_crud(
                    id=int(existed.id),  # type: ignore[arg-type]
                    data=ProduceBomManhourUpdateSchema(
                        project_code=project_code,
                        first_code=first_code,
                        bom_id=item.bom_id,
                        craft_id=item.craft_id,
                        manhour=item.manhour,
                    ),
                )
                updated += 1
            else:
                await crud.create_bommanhour_crud(
                    data=ProduceBomManhourCreateSchema(
                        project_code=project_code,
                        first_code=first_code,
                        bom_id=item.bom_id,
                        craft_id=item.craft_id,
                        manhour=item.manhour,
                    )
                )
                inserted += 1

        return {"inserted": inserted, "updated": updated, "deleted": deleted}

    @classmethod
    async def summary_missing_manhour_count_by_project_id_service(cls, auth: AuthSchema, project_id: int) -> dict:
        """
        根据项目ID统计缺失工时数量
        逻辑：
        1. 统计 produce_bom_manhour 中 project_code = 当前项目code 的不同 BOM ID 记录数 (已配置工时的 BOM 数量)
        2. 统计 produce_bom_route 中 project_code = 当前项目code 的不同 BOM ID 记录数 (已配置路线的 BOM 数量)
        3. 返回 差额 = 路线总数 - 工时已配置数
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

            # 2. 统计已配置工时的 BOM 数量 (按 bom_id 去重)
            configured_sql = text("SELECT COUNT(DISTINCT bom_id) FROM produce_bom_manhour WHERE project_code = :project_code")
            configured_result = await session.execute(configured_sql, {"project_code": project_code})
            configured_count = configured_result.scalar() or 0

            # 3. 统计已配置路线的 BOM 数量 (作为工时配置的基数)
            total_sql = text("SELECT COUNT(DISTINCT bom_id) FROM produce_bom_route WHERE project_code = :project_code")
            total_result = await session.execute(total_sql, {"project_code": project_code})
            total_count = total_result.scalar() or 0

            missing_count = total_count - configured_count
            # log.info(f"[getMissingManhourProjectList] 项目ID: {project_id}, 项目code: {project_code}, 路线总数: {total_count}, 工时已配: {configured_count}, 差额: {missing_count}")
            return {"project_id": project_id, "missing_count": max(0, missing_count)}

    @classmethod
    async def summary_missing_manhour_count_by_first_id_service(cls, auth: AuthSchema, first_id: int) -> dict:
        """
        根据 first_id（点击的 BOM 的 ID）统计缺失工时数量
        逻辑：
        1. 统计 produce_bom_manhour 中 first_code = 当前BOM code 的不同 BOM ID 记录数
        2. 统计 produce_bom_route 中 first_code = 当前BOM code 的不同 BOM ID 记录数
        3. 返回 差额 = 路线总数 - 工时已配置数
        """
        from sqlalchemy import text
        from app.core.database import async_db_session
        from app.core.logger import log

        async with async_db_session() as session:
            # 1. 获取 BOM code
            bom_sql = text("SELECT code FROM data_bom WHERE id = :first_id")
            bom_result = await session.execute(bom_sql, {"first_id": first_id})
            bom_row = bom_result.fetchone()
            if not bom_row:
                return {"first_id": first_id, "missing_count": 0}
            bom_code = bom_row[0]

            # 2. 统计已配置工时的 BOM 数量 (按 bom_id 去重)
            configured_sql = text("SELECT COUNT(DISTINCT bom_id) FROM produce_bom_manhour WHERE first_code = :bom_code")
            configured_result = await session.execute(configured_sql, {"bom_code": bom_code})
            configured_count = configured_result.scalar() or 0

            # 3. 统计已配置路线的 BOM 数量 (作为工时配置的基数)
            total_sql = text("SELECT COUNT(DISTINCT bom_id) FROM produce_bom_route WHERE first_code = :bom_code")
            total_result = await session.execute(total_sql, {"bom_code": bom_code})
            total_count = total_result.scalar() or 0

            missing_count = total_count - configured_count
            # log.info(f"[getMissingManhourBomPreview] BOM ID: {first_id}, BOM code: {bom_code}, 路线总数: {total_count}, 工时已配: {configured_count}, 差额: {missing_count}")
            return {"first_id": first_id, "missing_count": max(0, missing_count)}

    @classmethod
    async def summary_missing_order_count_by_project_id_service(cls, auth: AuthSchema, project_id: int) -> dict:
        """
        根据项目ID统计缺失工单数量
        逻辑：
        1. 获取项目编码 (project_code)
        2. 获取 data_bom 表中 parent_code = 项目编码 的记录 ID 列表
        3. 统计 produce_bom_manhour 表中 bom_id 在 ID 列表中的记录总数
        4. 统计 produce_order 表中 bom_id 在 ID 列表中的记录总数
        5. 返回 差额 = 工时记录数 - 工单记录数
        """
        # 复用批量逻辑
        res = await cls.summary_batch_missing_order_count_service(auth=auth, payload=ProduceBatchProjectIdSchema(project_ids=[project_id]))
        return {"project_id": project_id, "missing_count": res.get(project_id, 0)}

    @classmethod
    async def summary_batch_missing_order_count_service(cls, auth: AuthSchema, payload: ProduceBatchProjectIdSchema) -> dict[int, int]:
        """
        批量统计缺失工单数量
        """
        project_ids = payload.project_ids
        if not project_ids:
            return {}

        # 1. 获取项目 ID -> code 映射
        proj_sql = select(DataProjectModel.id, DataProjectModel.code).where(DataProjectModel.id.in_(project_ids))
        proj_res = await auth.db.execute(proj_sql)
        proj_map = {row.id: row.code for row in proj_res.all()}
        project_codes = list(proj_map.values())

        if not project_codes:
            return {pid: 0 for pid in project_ids}

        # 2. 获取 project_code -> list[bom_id] 映射
        bom_sql = select(DataBomModel.id, DataBomModel.parent_code).where(DataBomModel.parent_code.in_(project_codes))
        bom_res = await auth.db.execute(bom_sql)
        
        code_to_bom_ids = {}
        all_bom_ids = []
        for row in bom_res.all():
            code_to_bom_ids.setdefault(row.parent_code, []).append(row.id)
            all_bom_ids.append(row.id)

        if not all_bom_ids:
            return {pid: 0 for pid in project_ids}

        # 3. 统计 produce_bom_manhour 中 bom_id 的记录数
        manhour_sql = (
            select(ProduceBomManhourModel.bom_id, func.count(ProduceBomManhourModel.id).label("cnt"))
            .where(ProduceBomManhourModel.bom_id.in_(all_bom_ids))
            .group_by(ProduceBomManhourModel.bom_id)
        )
        manhour_res = await auth.db.execute(manhour_sql)
        bom_id_to_manhour_count = {row.bom_id: row.cnt for row in manhour_res.all()}

        # 4. 统计 produce_order 中 bom_id 的记录数
        order_sql = (
            select(ProduceOrderModel.bom_id, func.count(ProduceOrderModel.id).label("cnt"))
            .where(ProduceOrderModel.bom_id.in_(all_bom_ids))
            .group_by(ProduceOrderModel.bom_id)
        )
        order_res = await auth.db.execute(order_sql)
        bom_id_to_order_count = {row.bom_id: row.cnt for row in order_res.all()}

        # 5. 计算每个项目的差额
        result = {}
        for pid in project_ids:
            code = proj_map.get(pid)
            if not code:
                result[pid] = 0
                continue
            
            bom_ids = code_to_bom_ids.get(code, [])
            total_manhour_cnt = sum(bom_id_to_manhour_count.get(bid, 0) for bid in bom_ids)
            total_order_cnt = sum(bom_id_to_order_count.get(bid, 0) for bid in bom_ids)
            
            result[pid] = max(0, total_manhour_cnt - total_order_cnt)

        return result

    @classmethod
    async def summary_batch_bommanhour_service(cls, auth: AuthSchema, bom_ids: list[int], recursive: bool = True) -> dict[int, list[dict]]:
        """
        批量查询BOM工时分类汇总（可选是否递归汇总后代节点）
        """
        ids = [int(i) for i in bom_ids if i]
        if not ids:
            return {}

        # 如果不递归，直接查并按BOM ID分组
        if not recursive:
            sql = (
                select(
                    ProduceBomManhourModel.bom_id,
                    ProduceBomManhourModel.manhour,
                    ProduceCraftModel.name.label("craft_name")
                )
                .join(ProduceCraftModel, ProduceBomManhourModel.craft_id == ProduceCraftModel.id)
                .where(ProduceBomManhourModel.bom_id.in_(ids))
            )
            result = await auth.db.execute(sql)
            rows = result.all()
            
            res: dict[int, list[dict]] = {}
            for row in rows:
                if row.bom_id is not None:
                    res.setdefault(int(row.bom_id), []).append({
                        "craft_name": row.craft_name,
                        "manhour": row.manhour
                    })
            return res

        # 1. 获取请求的BOM节点信息（代号和根代号）
        bom_sql = select(DataBomModel.id, DataBomModel.code, DataBomModel.first_code).where(DataBomModel.id.in_(ids))
        bom_result = await auth.db.execute(bom_sql)
        requested_rows = bom_result.all()
        if not requested_rows:
            return {}

        first_codes = list(set([row.first_code for row in requested_rows]))
        
        # 2. 获取涉及到的所有根代号下的全部BOM节点，用于在内存中构建树结构
        all_bom_sql = select(DataBomModel.id, DataBomModel.code, DataBomModel.parent_code, DataBomModel.first_code).where(DataBomModel.first_code.in_(first_codes))
        all_bom_result = await auth.db.execute(all_bom_sql)
        all_boms = all_bom_result.all()

        # 构建映射： (first_code, parent_code) -> [child_id, ...]
        children_map = {}
        # 构建映射： id -> (code, first_code)
        id_to_info = {}
        for row in all_boms:
            id_to_info[row.id] = (row.code, row.first_code)
            key = (row.first_code, row.parent_code)
            children_map.setdefault(key, []).append(row.id)

        # 递归函数：获取节点及其所有后代的ID（带缓存以优化性能）
        memo = {}
        def get_descendant_ids(bom_id):
            if bom_id in memo:
                return memo[bom_id]
            
            # 使用 set 防止循环引用（虽然 BOM 树理论上不会有循环）
            results = {bom_id}
            code, first_code = id_to_info.get(bom_id, (None, None))
            if code:
                children = children_map.get((first_code, code), [])
                for child_id in children:
                    results.update(get_descendant_ids(child_id))
            
            memo[bom_id] = results
            return results

        # 为每个请求的BOM计算其后代ID列表
        bom_to_all_ids = {}
        all_involved_ids = set()
        for row in requested_rows:
            desc_ids = get_descendant_ids(row.id)
            bom_to_all_ids[row.id] = list(desc_ids)
            all_involved_ids.update(desc_ids)

        # 3. 批量查询所有涉及节点的工时记录
        sql = (
            select(
                ProduceBomManhourModel.bom_id,
                ProduceBomManhourModel.manhour,
                ProduceCraftModel.name.label("craft_name")
            )
            .join(ProduceCraftModel, ProduceBomManhourModel.craft_id == ProduceCraftModel.id)
            .where(ProduceBomManhourModel.bom_id.in_(list(all_involved_ids)))
        )
        result = await auth.db.execute(sql)
        rows = result.all()

        # 按 bom_id 分组记录工时
        id_to_manhours = {}
        for row in rows:
            id_to_manhours.setdefault(row.bom_id, []).append({
                "craft_name": row.craft_name,
                "manhour": row.manhour
            })

        # 4. 执行分类汇总
        res: dict[int, list[dict]] = {}
        for bom_id, sub_ids in bom_to_all_ids.items():
            craft_summary = {} # craft_name -> total_manhour
            for s_id in sub_ids:
                m_list = id_to_manhours.get(s_id, [])
                for m in m_list:
                    cname = m["craft_name"]
                    val = m["manhour"]
                    craft_summary[cname] = craft_summary.get(cname, 0) + val
            
            res[bom_id] = [
                {"craft_name": cname, "manhour": val}
                for cname, val in craft_summary.items()
                if val > 0
            ]

        return res

    @classmethod
    async def summary_craft_batch_bommanhour_service(cls, auth: AuthSchema, bom_ids: list[int]) -> dict[int, dict[int, int]]:
        ids = [int(i) for i in bom_ids if i]
        if not ids:
            return {}

        sql = (
            select(
                ProduceBomManhourModel.bom_id,
                ProduceBomManhourModel.craft_id,
                func.sum(ProduceBomManhourModel.manhour).label("total_manhour"),
            )
            .select_from(ProduceBomManhourModel)
            .where(ProduceBomManhourModel.bom_id.in_(ids), ProduceBomManhourModel.manhour > 0)
            .group_by(ProduceBomManhourModel.bom_id, ProduceBomManhourModel.craft_id)
            .order_by(ProduceBomManhourModel.bom_id.asc(), ProduceBomManhourModel.craft_id.asc())
        )
        result = await auth.db.execute(sql)
        rows = result.fetchall()

        data: dict[int, dict[int, int]] = {}
        for bom_id, craft_id, total_manhour in rows:
            if bom_id is None or craft_id is None or total_manhour is None:
                continue
            data.setdefault(int(bom_id), {})
            data[int(bom_id)][int(craft_id)] = int(total_manhour)
        return data
    
    @classmethod
    async def update_bommanhour_service(cls, auth: AuthSchema, id: int, data: ProduceBomManhourUpdateSchema) -> dict:
        """
        更新
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        - data: ProduceBomManhourUpdateSchema - 更新数据
        
        返回:
        - dict - 更新结果
        """
        # 检查数据是否存在
        obj = await ProduceBomManhourCRUD(auth).get_by_id_bommanhour_crud(id=id)
        if not obj:
            raise CustomException(msg='更新失败，该数据不存在')
        
        # 检查唯一性约束
            
        obj = await ProduceBomManhourCRUD(auth).update_bommanhour_crud(id=id, data=data)
        return ProduceBomManhourOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def delete_bommanhour_service(cls, auth: AuthSchema, ids: list[int]) -> None:
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
            obj = await ProduceBomManhourCRUD(auth).get_by_id_bommanhour_crud(id=id)
            if not obj:
                raise CustomException(msg=f'删除失败，ID为{id}的数据不存在')
        await ProduceBomManhourCRUD(auth).delete_bommanhour_crud(ids=ids)
    
    @classmethod
    async def set_available_bommanhour_service(cls, auth: AuthSchema, data: BatchSetAvailable) -> None:
        """
        批量设置状态
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: BatchSetAvailable - 批量设置状态数据
        
        返回:
        - None
        """
        await ProduceBomManhourCRUD(auth).set_available_bommanhour_crud(ids=data.ids, status=data.status)
    
    @classmethod
    async def batch_export_bommanhour_service(cls, obj_list: list[dict]) -> bytes:
        """
        批量导出
        
        参数:
        - obj_list: list[dict] - 数据列表
        
        返回:
        - bytes - 导出的Excel文件内容
        """
        mapping_dict = {
            'id': '主键ID',
            'bom_id': 'BOM ID',
            'craft_id': '工序ID',
            'manhour': '工时',
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
    async def batch_import_bommanhour_service(cls, auth: AuthSchema, file: UploadFile, update_support: bool = False) -> str:
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
            '主键ID': 'id',
            'BOM ID': 'bom_id',
            '工序ID': 'craft_id',
            '工时': 'manhour',
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
                        "id": row['id'],
                        "bom_id": row['bom_id'],
                        "craft_id": row['craft_id'],
                        "manhour": row['manhour'],
                    }
                    # 使用CreateSchema做校验后入库
                    create_schema = ProduceBomManhourCreateSchema.model_validate(data)
                    
                    # 检查唯一性约束
                    
                    await ProduceBomManhourCRUD(auth).create_bommanhour_crud(data=create_schema)
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
    async def import_template_download_bommanhour_service(cls) -> bytes:
        """
        下载导入模板
        
        返回:
        - bytes - Excel文件的二进制数据
        """
        header_list = [
            '主键ID',
            'BOM ID',
            '工序ID',
            '工时',
        ]
        selector_header_list = []
        option_list = []
        
        
        return ExcelUtil.get_excel_template(
            header_list=header_list,
            selector_header_list=selector_header_list,
            option_list=option_list
        )
