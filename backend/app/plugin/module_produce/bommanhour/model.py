# -*- coding: utf-8 -*-

from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceBomManhourModel(ModelMixin, UserMixin):
    """
    BOM工时关联表
    """
    __tablename__: str = 'produce_bom_manhour'
    __table_args__: dict[str, str] = {'comment': 'BOM工时关联'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    project_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='项目编码')
    first_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='一级代号')
    bom_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='BOM ID')
    craft_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工序ID')
    manhour: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工时')

