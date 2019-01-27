# coding:utf8

from flask import Blueprint

KanBan = Blueprint('KanBan',__name__)

from . import views