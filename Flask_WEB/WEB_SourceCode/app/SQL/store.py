# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
# from config import engine_236, engine_253
from app.config import engine_236, engine_253
from app.models import FPStore, STStore

base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()

def FPStoreSUM():
    FPStoreSUMList = []
    for varList in ses_236.query(func.sum(FPStore.nStockQty)).all():
        for var in varList:
            FPStoreQty = int(var)
            varDict = {
                'FPStoreQty' : FPStoreQty
            }
            FPStoreSUMList.append(varDict)
    return FPStoreSUMList

def FPStoreLT():
    FPStoreSUMList = []
    for varList in ses_236.query(func.sum(FPStore.nStockQty)).filter(FPStore.sLocation == '灵泰仓').all():
        for var in varList:
            FPStoreQty = int(var)
            varDict = {
                'FPStoreQty' : FPStoreQty
            }
            FPStoreSUMList.append(varDict)
    return FPStoreSUMList

# 成品库存
def STStoreSUM():
    STStoreSUMList = []
    varDict = {
        'sGrade':'A_B',
        'nStoreQty':0
    }
    STStoreSUMList.append(varDict)
    varDict = {
        'sGrade':'C_C1',
        'nStoreQty':0
    }
    STStoreSUMList.append(varDict)
    STStoreQtyA_B = 0
    STStoreQtyC_C1 = 0
    for varList in ses_236.query(func.sum(STStore.nStockQty) ,STStore.sGrade).group_by(STStore.sGrade).all():
        STStoreQty = int(varList[0])

        if varList[1] == 'A' or varList[1] == 'B':
            STStoreQtyA_B += STStoreQty
            STStoreSUMList[0]['nStoreQty'] = STStoreQtyA_B
        elif varList[1] == 'C' or varList[1] == 'C1':
            STStoreQtyC_C1 += STStoreQty            
            STStoreSUMList[1]['nStoreQty'] = STStoreQtyC_C1
    return STStoreSUMList