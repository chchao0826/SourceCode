# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
from app.config import engine_236 
from app.models import DyeKanBan

base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()


def getSimple(*args):
    getSimpleList = []
    for var in ses_236.query(DyeKanBan).filter(DyeKanBan.sType == '取样'):
        print(var)
        print('12121')
        pass
    return getSimpleList


def getAbnor(*args):
    getSimpleList = []
    for var in ses_236.query(DyeKanBan).filter(DyeKanBan.sType == '异常'):
        # print(var)
        pass
    return getSimpleList