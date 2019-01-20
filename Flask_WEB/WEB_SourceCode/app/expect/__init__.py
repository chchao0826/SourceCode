# coding:utf8

from flask import Blueprint

expect = Blueprint('expect',__name__)

from . import views