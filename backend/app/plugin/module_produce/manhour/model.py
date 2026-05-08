# -*- coding: utf-8 -*-

from datetime import datetime
from sqlalchemy import DateTime, Enum, BigInteger, Integer, Text, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class ProduceManhourModel(ModelMixin, UserMixin):
    """
    工时管理表
    """
    __tablename__: str = 'produce_manhour'
    __table_args__: dict[str, str] = {'comment': '工时管理'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    name: Mapped[str | None] = mapped_column(String(128), nullable=True, comment='零件名称')
    model: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='零件型号')
    material: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='材质')
    unit: Mapped[str | None] = mapped_column(String(16), nullable=True, comment='计算单位：g=重量 m=长度 p=件')
    unit_hour: Mapped[int | None] = mapped_column(BigInteger, nullable=True, comment='单位工时ms')
    blanking_ratio: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='下料工时比率')
    welding_ratio: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='铆焊工时比率')
    fitting_ratio: Mapped[int | None] = mapped_column(Integer, nullable=True, comment='装配工时比率')

