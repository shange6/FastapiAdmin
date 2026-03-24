# -*- coding: utf-8 -*-

from sqlalchemy import Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import MappedBase


class ProduceBomRouteModel(MappedBase):
    """
    BOM路线关联表
    """
    __tablename__: str = 'produce_bom_route'

    bom_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='BOMID', primary_key=True)
    route: Mapped[int] = mapped_column(Integer, nullable=False, comment='工艺路线', primary_key=True)

