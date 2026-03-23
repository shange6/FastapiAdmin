# -*- coding: utf-8 -*-

from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceCraftModel(ModelMixin, UserMixin):
    """
    工艺字典表
    """
    __tablename__: str = 'produce_craft'
    __table_args__: dict[str, str] = {'comment': '工艺字典'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    name: Mapped[str] = mapped_column(String(30), nullable=False, comment='工艺名称')

