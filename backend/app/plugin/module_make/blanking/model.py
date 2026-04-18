# -*- coding: utf-8 -*-

from datetime import datetime
from sqlalchemy import Integer, DateTime, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceMakeModel(ModelMixin, UserMixin):
    """
    制造流程主表
    """
    __tablename__: str = 'produce_make'
    __table_args__: dict[str, str] = {'comment': '制造流程主'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    project_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='项目ID')
    first_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='部件ID')
    bom_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='BOMID')
    order_no: Mapped[str | None] = mapped_column(String(32), nullable=True, comment='单号')
    project_code: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='项目代码')
    current_sort: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工艺序号')
    current_craft_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工艺ID')


class ProduceMakeFlowModel(ModelMixin, UserMixin):
    """
    制造流程执行表
    """
    __tablename__: str = 'produce_make_flow'
    __table_args__: dict[str, str] = {'comment': '制造流程执行表'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    project_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='项目ID')
    first_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='部件ID')
    make_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='制造ID')
    bom_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='BOMID')
    user_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='用户ID')
    sort: Mapped[int] = mapped_column(Integer, nullable=False, comment='工艺序号')
    craft_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='工艺ID')
    end_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.now, nullable=False, comment='完工时间')

