# -*- coding: utf-8 -*-

from sqlalchemy import Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceBomManhourModel(ModelMixin, UserMixin):
    """
    BOM工时关联表
    """
    __tablename__: str = 'produce_bom_manhour'
    __table_args__: dict[str, str] = {'comment': 'BOM工时关联'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    project_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='项目ID')
    first_id: Mapped[int] = mapped_column(Integer, nullable=False, comment='部件ID')
    bom_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='BOM ID')
    craft_id: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工序ID')
    manhour: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='工时')

