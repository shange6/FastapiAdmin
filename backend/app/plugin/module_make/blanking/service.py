# -*- coding: utf-8 -*-

import io
import pandas as pd
from fastapi import UploadFile

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_schema import BatchSetAvailable
from app.core.exceptions import CustomException
from app.core.logger import log
from app.utils.excel_util import ExcelUtil

from .crud import ProduceMakeCRUD, ProduceMakeFlowCRUD
from .schema import (
    ProduceMakeCreateSchema,
    ProduceMakeUpdateSchema,
    ProduceMakeOutSchema,
    ProduceMakeQueryParam,
    ProduceMakeFlowCreateSchema,
    ProduceMakeFlowOutSchema
)


class ProduceMakeService:
    """
    制造流程主服务层
    """
    
    @classmethod
    async def detail_blanking_service(cls, auth: AuthSchema, id: int) -> dict:
        """
        详情
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        
        返回:
        - dict - 数据详情
        """
        obj = await ProduceMakeCRUD(auth).get_by_id_blanking_crud(id=id)
        if not obj:
            raise CustomException(msg="该数据不存在")
        return ProduceMakeOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def list_blanking_service(cls, auth: AuthSchema, search: ProduceMakeQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询
        
        参数:
        - auth: AuthSchema - 认证信息
        - search: ProduceMakeQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await ProduceMakeCRUD(auth).list_blanking_crud(search=search_dict, order_by=order_by)
        return [ProduceMakeOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def page_blanking_service(cls, auth: AuthSchema, page_no: int | None = None, page_size: int | None = None, search: ProduceMakeQueryParam | None = None, order_by: list[dict] | None = None) -> dict:
        """
        查询制造流程主列表（支持分页和全量）
        
        参数:
        - auth: AuthSchema - 认证信息
        - page_no: int | None - 页码
        - page_size: int | None - 每页数量
        - search: ProduceMakeQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - dict - 查询结果
        """
        search_dict = search.__dict__ if search else {}
        order_by_list = order_by or [{'id': 'asc'}]
        
        if page_no is not None and page_size is not None:
            # 分页查询
            offset = (page_no - 1) * page_size
            result = await ProduceMakeCRUD(auth).page_blanking_crud(
                offset=offset,
                limit=page_size,
                order_by=order_by_list,
                search=search_dict
            )
            return result
        else:
            # 全量查询
            obj_list = await ProduceMakeCRUD(auth).list_blanking_crud(
                search=search_dict,
                order_by=order_by_list
            )
            items = [ProduceMakeOutSchema.model_validate(obj).model_dump() for obj in obj_list]
            return {
                "items": items,
                "total": len(items)
            }
    
    @classmethod
    async def create_blanking_service(cls, auth: AuthSchema, data: ProduceMakeCreateSchema) -> dict:
        """
        创建
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: ProduceMakeCreateSchema - 创建数据
        
        返回:
        - dict - 创建结果
        """
        obj = await ProduceMakeCRUD(auth).create_blanking_crud(data=data)
        return ProduceMakeOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def update_blanking_service(cls, auth: AuthSchema, id: int, data: ProduceMakeUpdateSchema) -> dict:
        """
        更新
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        - data: ProduceMakeUpdateSchema - 更新数据
        
        返回:
        - dict - 更新结果
        """
        # 检查数据是否存在
        obj = await ProduceMakeCRUD(auth).get_by_id_blanking_crud(id=id)
        if not obj:
            raise CustomException(msg='更新失败，该数据不存在')
        
        # 检查唯一性约束
            
        obj = await ProduceMakeCRUD(auth).update_blanking_crud(id=id, data=data)
        return ProduceMakeOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def delete_blanking_service(cls, auth: AuthSchema, ids: list[int]) -> None:
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
            obj = await ProduceMakeCRUD(auth).get_by_id_blanking_crud(id=id)
            if not obj:
                raise CustomException(msg=f'删除失败，ID为{id}的数据不存在')
        await ProduceMakeCRUD(auth).delete_blanking_crud(ids=ids)
    
    @classmethod
    async def set_available_blanking_service(cls, auth: AuthSchema, data: BatchSetAvailable) -> None:
        """
        批量设置状态
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: BatchSetAvailable - 批量设置状态数据
        
        返回:
        - None
        """
        await ProduceMakeCRUD(auth).set_available_blanking_crud(ids=data.ids, status=data.status)
    
    @classmethod
    async def batch_export_blanking_service(cls, obj_list: list[dict]) -> bytes:
        """
        批量导出
        
        参数:
        - obj_list: list[dict] - 数据列表
        
        返回:
        - bytes - 导出的Excel文件内容
        """
        mapping_dict = {
            'bom_id': 'BOMID',
            'order_no': '单号',
            'project_code': '项目代码',
            'current_sort': '工艺序号',
            'current_craft_id': '工艺ID',
            'id': '主键ID',
            'uuid': 'UUID',
            'status': '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停',
            'description': '备注/描述',
            'created_time': '创建时间',
            'updated_time': '更新时间',
            'created_id': '创建人ID',
            'updated_id': '更新人ID',
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
    async def batch_import_blanking_service(cls, auth: AuthSchema, file: UploadFile, update_support: bool = False) -> str:
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
            '单号': 'order_no',
            '项目代码': 'project_code',
            '工艺序号': 'current_sort',
            '工艺ID': 'current_craft_id',
            '主键ID': 'id',
            'UUID': 'uuid',
            '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停': 'status',
            '备注/描述': 'description',
            '创建时间': 'created_time',
            '更新时间': 'updated_time',
            '创建人ID': 'created_id',
            '更新人ID': 'updated_id',
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
                        "order_no": row['order_no'],
                        "project_code": row['project_code'],
                        "current_sort": row['current_sort'],
                        "current_craft_id": row['current_craft_id'],
                        "id": row['id'],
                        "uuid": row['uuid'],
                        "status": row['status'],
                        "description": row['description'],
                        "created_time": row['created_time'],
                        "updated_time": row['updated_time'],
                        "created_id": row['created_id'],
                        "updated_id": row['updated_id'],
                    }
                    # 使用CreateSchema做校验后入库
                    create_schema = ProduceMakeCreateSchema.model_validate(data)
                    
                    # 检查唯一性约束
                    
                    await ProduceMakeCRUD(auth).create_blanking_crud(data=create_schema)
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
    async def import_template_download_blanking_service(cls) -> bytes:
        """
        下载导入模板
        
        返回:
        - bytes - Excel文件的二进制数据
        """
        header_list = [
            'BOMID',
            '单号',
            '项目代码',
            '工艺序号',
            '工艺ID',
            '主键ID',
            'UUID',
            '状态 0=待生产 1=生产中 2=已完成 3=已取消 4=已暂停',
            '备注/描述',
            '创建时间',
            '更新时间',
            '创建人ID',
            '更新人ID',
        ]
        selector_header_list = []
        option_list = []
        
        
        return ExcelUtil.get_excel_template(
            header_list=header_list,
            selector_header_list=selector_header_list,
            option_list=option_list
        )

    @classmethod
    async def sync_produce_make_by_bom_service(cls, auth: AuthSchema, bom_id: int) -> dict:
        """
        根据BOM ID同步更新: 自己及所有后代共用当前BOM的工单号并同步至produce_make表
        """
        from app.core.database import async_db_session
        from sqlalchemy import text
        
        async with async_db_session() as session:
            # 1. 获取当前根节点BOM的基本信息
            bom_result = await session.execute(
                text("SELECT code, parent_code FROM data_bom WHERE id = :bom_id"),
                {"bom_id": bom_id}
            )
            bom_row = bom_result.fetchone()
            if not bom_row:
                raise CustomException(msg=f"BOM不存在: {bom_id}")

            current_root_code = bom_row[0]
            # 这里的 project_code 取根节点的 parent_code
            project_code = bom_row[1]

            # 2. 【核心步】获取当前BOM自己的工单号及关联信息 (用于后续全员赋值)
            order_result = await session.execute(
                text("SELECT no, project_code, first_code FROM produce_order WHERE bom_id = :bom_id LIMIT 1"),
                {"bom_id": bom_id}
            )
            order_row = order_result.fetchone()
            if not order_row:
                raise CustomException(msg=f"当前BOM(ID:{bom_id})尚未生成工单，无法执行同步")
            
            shared_order_no = order_row[0] # 这就是我们要共享给后代的唯一工单号
            project_code = order_row[1]
            first_code = order_row[2]

            # 3. 递归获取所有后代及自己
            tree_result = await session.execute(
                text("""
                    WITH RECURSIVE bom_tree AS (
                        SELECT id, code, parent_code FROM data_bom WHERE id = :bom_id
                        UNION ALL
                        SELECT d.id, d.code, d.parent_code FROM data_bom d
                        INNER JOIN bom_tree bt ON d.parent_code = bt.code
                    )
                    SELECT id FROM bom_tree
                """),
                {"bom_id": bom_id}
            )
            all_bom_ids = [row[0] for row in tree_result.fetchall()]

            # 4. 批量获取工艺路线映射
            route_result = await session.execute(
                text("SELECT bom_id, route FROM produce_bom_route WHERE bom_id IN :bom_ids"),
                {"bom_ids": tuple(all_bom_ids)}
            )
            bom_route_map = {row[0]: row[1] for row in route_result.fetchall()}

            # 5. 批量获取路线对应的第一道工序 (父工艺)
            unique_routes = list(set(bom_route_map.values()))
            craft_ids_by_route = {}
            if unique_routes:
                craft_result = await session.execute(
                    text("SELECT route, craft_id FROM produce_craft_route WHERE route IN :routes AND sort = 1"),
                    {"routes": tuple(unique_routes)}
                )
                craft_ids_by_route = {row[0]: row[1] for row in craft_result.fetchall()}

            # 6. 循环处理
            updated_count = 0
            for desc_bom_id in all_bom_ids:
                route = bom_route_map.get(desc_bom_id)
                if not route: continue # 无工艺路线的零件不入制造表
                
                craft_id = craft_ids_by_route.get(route)
                if not craft_id: continue

                # 检查是否存在记录
                exist_result = await session.execute(
                    text("SELECT id FROM produce_make WHERE bom_id = :bom_id"),
                    {"bom_id": desc_bom_id}
                )
                exist_row = exist_result.fetchone()

                if exist_row:
                    # 更新逻辑：强制赋值根节点的共享工单号
                    await session.execute(
                        text("""
                            UPDATE produce_make
                            SET project_code = :project_code,
                                first_code = :first_code,
                                current_craft_id = :craft_id,
                                current_sort = 1,
                                order_no = :order_no,
                                updated_id = :user_id
                            WHERE bom_id = :bom_id
                        """),
                        {
                            "bom_id": desc_bom_id,
                            "project_code": project_code,
                            "first_code": first_code,
                            "craft_id": craft_id,
                            "order_no": shared_order_no,
                            "user_id": auth.user.id
                        }
                    )
                else:
                    # 插入逻辑：强制赋值根节点的共享工单号
                    await session.execute(
                        text("""
                            INSERT INTO produce_make 
                            (project_code, first_code, bom_id, current_craft_id, current_sort, status, order_no, created_id, updated_id)
                            VALUES (:project_code, :first_code, :bom_id, :craft_id, 1, '0', :order_no, :user_id, :user_id)
                        """),
                        {
                            "project_code": project_code,
                            "first_code": first_code,
                            "bom_id": desc_bom_id,
                            "craft_id": craft_id,
                            "order_no": shared_order_no,
                            "user_id": auth.user.id
                        }
                    )
                updated_count += 1

            await session.commit()
            return {"updated_count": updated_count, "shared_order_no": shared_order_no}

    @classmethod
    async def summary_make_by_orders_service(cls, auth: AuthSchema, order_nos: list[str], craft_id: int) -> dict:
        """
        按单号和工艺ID统计待办数量
        
        参数:
        - auth: AuthSchema - 认证信息
        - order_nos: list[str] - 单号列表
        - craft_id: int - 工艺ID
        
        返回:
        - dict - {order_no: count}
        """
        from sqlalchemy import text
        if not order_nos:
            return {}
            
        res = await auth.db.execute(
            text("SELECT order_no, COUNT(*) as cnt FROM produce_make WHERE order_no IN :nos AND current_craft_id = :cid GROUP BY order_no"),
            {"nos": tuple(order_nos), "cid": craft_id}
        )
        return {row[0]: row[1] for row in res.fetchall()}

    @classmethod
    async def submit_blanking_flow_service(cls, auth: AuthSchema, data: ProduceMakeFlowCreateSchema) -> dict:
        """
        提交制造流程执行记录，并自动流转 produce_make 表的当前工序
        """
        from sqlalchemy import text
        from loguru import logger

        # 1. 检查是否存在重复记录
        exist = await auth.db.execute(
            text("SELECT id FROM produce_make_flow WHERE make_id=:m AND bom_id=:b AND sort=:s AND craft_id=:c"),
            {"m": data.make_id, "b": data.bom_id, "s": data.sort, "c": data.craft_id}
        )
        if exist.fetchone():
            raise CustomException(msg="该记录已提交，请勿重复操作")

        # 2. 获取当前工序和工艺路线
        res = await auth.db.execute(
            text("""
                SELECT m.current_sort, r.route, m.project_code, m.first_code
                FROM produce_make m 
                LEFT JOIN produce_bom_route r ON m.bom_id = r.bom_id 
                WHERE m.id = :id
            """), {"id": data.make_id}
        )
        row = res.fetchone()
        if not row:
            raise CustomException(msg="未找到制造记录")
        
        cur_sort, route_id, project_code, first_code = row
        next_sort, next_craft_id = 0, 0 # 默认最后一道工序后置为0

        # 3. 寻找下一工序
        if route_id:
            next_res = await auth.db.execute(
                text("SELECT sort, craft_id FROM produce_craft_route WHERE route=:r AND sort=:s"),
                {"r": route_id, "s": cur_sort + 1}
            )
            next_row = next_res.fetchone()
            if next_row:
                next_sort, next_craft_id = next_row

        # 4. 执行更新
        data.project_code = project_code
        data.first_code = first_code
        obj = await ProduceMakeFlowCRUD(auth).create_flow_crud(data=data)
        await auth.db.execute(
            text("UPDATE produce_make SET current_sort=:s, current_craft_id=:c, updated_id=:u WHERE id=:id"),
            {"s": next_sort, "c": next_craft_id, "u": auth.user.id, "id": data.make_id}
        )
        
        logger.info(f"工序流转: make_id={data.make_id}, next_sort={next_sort}, next_craft={next_craft_id}")
        await auth.db.commit()
        return ProduceMakeFlowOutSchema.model_validate(obj).model_dump()