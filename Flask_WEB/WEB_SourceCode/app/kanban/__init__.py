# coding:utf8

from flask import Blueprint

kanban = Blueprint('kanban',__name__)

from . import views