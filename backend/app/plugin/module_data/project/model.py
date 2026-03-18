# -*- coding: utf-8 -*-

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class DataProjectModel(ModelMixin, UserMixin):
    """
    项目信息表
    """
    __tablename__: str = 'data_project'
    __table_args__: dict[str, str] = {'comment': '项目信息'}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    code: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='项目编码')
    name: Mapped[str | None] = mapped_column(String(255), nullable=True, comment='项目名称')
    no: Mapped[str | None] = mapped_column(String(64), nullable=True, comment='项目编号')

