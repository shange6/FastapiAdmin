# -*- coding: utf-8 -*-

import io
import datetime
import pandas as pd
from fastapi import UploadFile
from sqlalchemy import select

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_schema import BatchSetAvailable
from app.core.exceptions import CustomException
from app.core.logger import log
from app.utils.excel_util import ExcelUtil

from .crud import ProduceOrderCRUD
from .model import ProduceOrderModel
from ...module_data.bom.model import DataBomModel
from .schema import (
    ProduceOrderCreateSchema,
    ProduceOrderUpdateSchema,
    ProduceOrderOutSchema,
    ProduceOrderQueryParam,
    ProduceOrderUpsertBatchSchema,
)


class ProduceOrderService:
    """
    工单服务层
    """
    
    @classmethod
    async def detail_order_service(cls, auth: AuthSchema, id: int) -> dict:
        """
        详情
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        
        返回:
        - dict - 数据详情
        """
        obj = await ProduceOrderCRUD(auth).get_by_id_order_crud(id=id)
        if not obj:
            raise CustomException(msg="该数据不存在")
        return ProduceOrderOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def list_order_service(cls, auth: AuthSchema, search: ProduceOrderQueryParam | None = None, order_by: list[dict] | None = None) -> list[dict]:
        """
        列表查询
        
        参数:
        - auth: AuthSchema - 认证信息
        - search: ProduceOrderQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - list[dict] - 数据列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await ProduceOrderCRUD(auth).list_order_crud(search=search_dict, order_by=order_by)
        return [ProduceOrderOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def summary_batch_order_service(cls, auth: AuthSchema, bom_ids: list[int]) -> dict[int, str]:
        ids = [int(i) for i in bom_ids if i]
        if not ids:
            return {}

        sql = (
            select(ProduceOrderModel.bom_id, ProduceOrderModel.no)
            .where(ProduceOrderModel.bom_id.in_(ids))
            .group_by(ProduceOrderModel.bom_id, ProduceOrderModel.no)
        )
        result = await auth.db.execute(sql)
        rows = result.all()

        res: dict[int, str] = {}
        for row in rows:
            bid, no = row
            if bid is not None and no:
                # 相同 bom_id 对应的 no 应该是一样的，这里简单覆盖即可
                res[int(bid)] = str(no)

        return res

    @classmethod
    async def page_order_service(cls, auth: AuthSchema, page_no: int, page_size: int, search: ProduceOrderQueryParam | None = None, order_by: list[dict] | None = None) -> dict:
        """
        分页查询（数据库分页）
        
        参数:
        - auth: AuthSchema - 认证信息
        - page_no: int - 页码
        - page_size: int - 每页数量
        - search: ProduceOrderQueryParam | None - 查询参数
        - order_by: list[dict] | None - 排序参数
        
        返回:
        - dict - 分页查询结果
        """
        search_dict = search.__dict__ if search else {}
        order_by_list = order_by or [{'id': 'asc'}]
        offset = (page_no - 1) * page_size
        result = await ProduceOrderCRUD(auth).page_order_crud(
            offset=offset,
            limit=page_size,
            order_by=order_by_list,
            search=search_dict
        )
        return result
    
    @classmethod
    async def create_order_service(cls, auth: AuthSchema, data: ProduceOrderCreateSchema) -> dict:
        """
        创建
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: ProduceOrderCreateSchema - 创建数据
        
        返回:
        - dict - 创建结果
        """
        obj = await ProduceOrderCRUD(auth).create_order_crud(data=data)
        return ProduceOrderOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def update_order_service(cls, auth: AuthSchema, id: int, data: ProduceOrderUpdateSchema) -> dict:
        """
        更新
        
        参数:
        - auth: AuthSchema - 认证信息
        - id: int - 数据ID
        - data: ProduceOrderUpdateSchema - 更新数据
        
        返回:
        - dict - 更新结果
        """
        # 检查数据是否存在
        obj = await ProduceOrderCRUD(auth).get_by_id_order_crud(id=id)
        if not obj:
            raise CustomException(msg='更新失败，该数据不存在')
        
        # 检查唯一性约束
            
        obj = await ProduceOrderCRUD(auth).update_order_crud(id=id, data=data)
        return ProduceOrderOutSchema.model_validate(obj).model_dump()
    
    @classmethod
    async def delete_order_service(cls, auth: AuthSchema, ids: list[int]) -> None:
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
            obj = await ProduceOrderCRUD(auth).get_by_id_order_crud(id=id)
            if not obj:
                raise CustomException(msg=f'删除失败，ID为{id}的数据不存在')
        await ProduceOrderCRUD(auth).delete_order_crud(ids=ids)
    
    @classmethod
    async def set_available_order_service(cls, auth: AuthSchema, data: BatchSetAvailable) -> None:
        """
        批量设置状态
        
        参数:
        - auth: AuthSchema - 认证信息
        - data: BatchSetAvailable - 批量设置状态数据
        
        返回:
        - None
        """
        await ProduceOrderCRUD(auth).set_available_order_crud(ids=data.ids, status=data.status)
    
    @classmethod
    async def _get_max_serial(cls, auth: AuthSchema, yy: str) -> int:
        """
        获取当年最大的序列号
        """
        sql = (
            select(ProduceOrderModel.no)
            .where(ProduceOrderModel.no.like(f"{yy}%"))
            .order_by(ProduceOrderModel.no.desc())
            .limit(1)
        )
        result = await auth.db.execute(sql)
        max_no = result.scalar()
        if max_no:
            try:
                return int(max_no[-3:])
            except (ValueError, TypeError):
                pass
        return 0

    @classmethod
    async def upsert_batch_order_service(cls, auth: AuthSchema, data: ProduceOrderUpsertBatchSchema) -> dict:
        created = 0
        updated = 0
        items = data.items or []
        crud = ProduceOrderCRUD(auth)
        
        # 预先查询这些 BOM 是否已有单号及编码信息
        bom_ids = list(set(item.bom_id for item in items))
        bom_no_map: dict[int, str] = {}
        bom_info_map: dict[int, tuple[str, str]] = {}
        if bom_ids:
            # 查询单号
            sql = select(ProduceOrderModel.bom_id, ProduceOrderModel.no).where(
                ProduceOrderModel.bom_id.in_(bom_ids),
                ProduceOrderModel.no.is_not(None)
            ).group_by(ProduceOrderModel.bom_id, ProduceOrderModel.no)
            res = await auth.db.execute(sql)
            for bid, no in res.all():
                if bid is not None and no:
                    bom_no_map[int(bid)] = str(no)
            
            # 查询编码信息
            bom_sql = select(DataBomModel.id, DataBomModel.project_code, DataBomModel.first_code).where(DataBomModel.id.in_(bom_ids))
            bom_res = await auth.db.execute(bom_sql)
            bom_info_map = {row.id: (row.project_code, row.first_code) for row in bom_res.all()}

        now = datetime.datetime.now()
        yy = now.strftime('%y')
        # 获取当前数据库中最大的序列号作为起始
        current_max_serial = await cls._get_max_serial(auth, yy)

        for item in items:
            exists = await crud.get(bom_id=item.bom_id, craft_id=item.craft_id)
            
            # 优先从 DataBomModel 获取编码，确保一致性
            bom_info = bom_info_map.get(item.bom_id)
            project_code = bom_info[0] if bom_info else item.project_code
            first_code = bom_info[1] if bom_info else item.first_code

            # 确定单号：如果前端没传，则尝试从已有记录获取，否则生成新的
            order_no = item.no
            if not order_no:
                order_no = bom_no_map.get(item.bom_id)
            
            if not order_no:
                # 生成新单号: 年份后两位 + 三位递增数字
                current_max_serial += 1
                order_no = f"{yy}{str(current_max_serial).zfill(3)}"
                bom_no_map[item.bom_id] = order_no # 同一批次后续 item 复用

            payload = {
                "no": order_no,
                "project_code": project_code,
                "first_code": first_code,
                "bom_id": item.bom_id,
                "craft_id": item.craft_id,
                "man_hour": item.man_hour,
                "plan_count": item.plan_count,
                "real_count": item.real_count,
                "plan_date": item.plan_date,
                "real_date": item.real_date,
                "plan_user": item.plan_user,
                "status": item.status,
                "description": item.description,
            }
            if exists:
                await crud.update_order_crud(id=exists.id, data=ProduceOrderUpdateSchema.model_validate(payload))
                updated += 1
            else:
                await crud.create_order_crud(data=ProduceOrderCreateSchema.model_validate(payload))
                created += 1
        return {"created": created, "updated": updated, "total": len(items)}
    
    @classmethod
    async def batch_export_order_service(cls, obj_list: list[dict]) -> bytes:
        """
        批量导出
        
        参数:
        - obj_list: list[dict] - 数据列表
        
        返回:
        - bytes - 导出的Excel文件内容
        """
        mapping_dict = {
            'bom_id': 'BOM ID',
            'craft_id': '子工艺ID',
            'man_hour': '工时',
            'plan_count': '计划数量',
            'real_count': '实际数量',
            'plan_date': '计划日期',
            'real_date': '实际日期',
            'id': '工单ID',
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
    async def batch_import_order_service(cls, auth: AuthSchema, file: UploadFile, update_support: bool = False) -> str:
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
            'BOM ID': 'bom_id',
            '子工艺ID': 'craft_id',
            '工时': 'man_hour',
            '计划数量': 'plan_count',
            '实际数量': 'real_count',
            '计划日期': 'plan_date',
            '实际日期': 'real_date',
            '工单ID': 'id',
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
                        "craft_id": row['craft_id'],
                        "man_hour": row['man_hour'],
                        "plan_count": row['plan_count'],
                        "real_count": row['real_count'],
                        "plan_date": row['plan_date'],
                        "real_date": row['real_date'],
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
                    create_schema = ProduceOrderCreateSchema.model_validate(data)
                    
                    # 检查唯一性约束
                    
                    await ProduceOrderCRUD(auth).create_order_crud(data=create_schema)
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
    async def import_template_download_order_service(cls) -> bytes:
        """
        下载导入模板
        
        返回:
        - bytes - Excel文件的二进制数据
        """
        header_list = [
            'BOM ID',
            '子工艺ID',
            '工时',
            '计划数量',
            '实际数量',
            '计划日期',
            '实际日期',
            '工单ID',
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
