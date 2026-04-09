# -*- coding: utf-8 -*-

from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import MappedBase


class ProduceCraftModel(MappedBase):
    """
    工艺字典表
    """
    __tablename__: str = 'produce_craft'
    __table_args__: dict[str, str] = {'comment': '工艺字典'}
    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    name: Mapped[str] = mapped_column(String(30), nullable=False, comment='工艺名称')
    parent_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    has_child: Mapped[int | None] = mapped_column(Integer, nullable=True)
