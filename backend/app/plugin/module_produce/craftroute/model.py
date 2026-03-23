# -*- coding: utf-8 -*-

from datetime import datetime
from sqlalchemy import DateTime, String, Text, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceCraftRouteModel(ModelMixin, UserMixin):
    """
    工艺路线表
    """
    __tablename__: str = 'produce_craft_route'
    __table_args__: dict[str, str] = {'comment': '工艺路线'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    route: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工艺路线')
    sort: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='排序')
    craft_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工艺ID')

