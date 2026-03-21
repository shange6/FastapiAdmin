# -*- coding: utf-8 -*-

from datetime import datetime
from sqlalchemy import String, Text, DateTime, Float, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class DataBomModel(ModelMixin, UserMixin):
    """
    BOM清单表
    """
    __tablename__: str = 'data_bom'
    __table_args__: dict[str, str] = {'comment': 'BOM清单'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    first_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='根代号')
    parent_code: Mapped[str] = mapped_column(String(64), nullable=False, comment='父代号')
    code: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='代号')
    spec: Mapped[str] = mapped_column(String(255), nullable=False, comment='名称')
    count: Mapped[int] = mapped_column(Integer, nullable=False, comment='数量')
    material: Mapped[str | None] = mapped_column(String(255), nullable=True, comment='材质')
    unit_mass: Mapped[float | None] = mapped_column(Float, nullable=True, comment='单重')
    total_mass: Mapped[float | None] = mapped_column(Float, nullable=True, comment='总重')
    remark: Mapped[str | None] = mapped_column(String(500), nullable=True, comment='备注')
    borrow: Mapped[bool] = mapped_column(Boolean, nullable=False, comment='是否借用')
    procure: Mapped[bool] = mapped_column(Boolean, nullable=False, comment='是否外购')
    noimage: Mapped[bool] = mapped_column(Boolean, nullable=False, comment='是否无图')
    figure: Mapped[bool] = mapped_column(Boolean, nullable=False, comment='是否附图')
