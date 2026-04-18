# -*- coding: utf-8 -*-

from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceBomRouteModel(ModelMixin, UserMixin):
    """
    BOM路线关联表
    """
    __tablename__: str = 'produce_bom_route'
    __table_args__: dict[str, str] = {'comment': 'BOM路线关联'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    project_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='项目编码')
    first_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='一级代号')
    bom_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='BOMID')
    route: Mapped[int] = mapped_column(Integer, nullable=False, comment='工艺路线')

