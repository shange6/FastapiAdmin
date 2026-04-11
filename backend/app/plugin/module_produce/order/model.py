# -*- coding: utf-8 -*-

from datetime import datetime
from datetime import date
from sqlalchemy import Text, Integer, Date, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceOrderModel(ModelMixin, UserMixin):
    """
    工单表
    """
    __tablename__: str = 'produce_order'
    __table_args__: dict[str, str] = {'comment': '工单'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    no: Mapped[str | None] = mapped_column(String(32), nullable=True, comment='单号')
    bom_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='BOM ID')
    craft_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='子工艺ID')
    man_hour: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工时')
    plan_count: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='计划数量')
    real_count: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='实际数量')
    plan_date: Mapped[date | None] = mapped_column(Date, nullable=True, comment='计划日期')
    real_date: Mapped[date | None] = mapped_column(Date, nullable=True, comment='实际日期')
    plan_user: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='计划用户')
    real_user: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='实际用户')
