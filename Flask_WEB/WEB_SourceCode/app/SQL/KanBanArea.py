# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
# from config import engine_236, engine_253
from app.config import engine_236, engine_253
from app.models import equipment, equipmentStatus, workingwip, dataCenter
from app.SQL.store import FPStoreSUM, FPStoreLT, STStoreSUM

# from config import engine_236, engine_253
# from models import equipment, equipmentStatus

base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()

# 通过机台搜索机台状态
def FactoryFloorPlan(*args):
    FactoryFloorPlan = []
    for var_eq in args:
        for var in ses_236.query(equipmentStatus.ipbCommonDataEquipmentID, equipmentStatus.sStatusColor, equipment.id, equipment.sEquipmentNo, equipmentStatus.sStatus)\
        .filter(and_(equipmentStatus.ipbCommonDataEquipmentID == equipment.id, equipment.sEquipmentNo == var_eq)).join(equipment, equipment.id == equipmentStatus.ipbCommonDataEquipmentID).order_by(equipment.nRowNumber):
            varDict = {
                'sEquipmentNo':var.sEquipmentNo,
                'sStatus':var.sStatus,
                'sStatusColor':var.sStatusColor
            }
            FactoryFloorPlan.append(varDict)
    # print(FactoryFloorPlan)
    return FactoryFloorPlan

# 设置工段的WIP的上限
def WIPSearch(*args):
    varList = []
    for var in ses_236.query(workingwip).order_by(workingwip.id):
        varDict = {
            'id':var.id,
            'sWorkingProcedureName':var.sWorkingProcedureName,
            'sCeiling': var.sCeiling
        }
        varList.append(varDict)
    print(varList)
    return varList

# WIP上限更新
def WIPSet(*args):
    for var in args:
        for var_work in var:
            ses_236.query(workingwip).filter(workingwip.sWorkingProcedureName == var_work['sWorkingProcedureName']).update({'sCeiling':var_work['sCeiling']})

    return ses_236.commit(), ses_236.close()

# 计算所有在线卡号的数量(分工段)
def cardNumber():
    cardNumberList = []
    for var in ses_236.query(func.count(dataCenter.sWorkingProcedureName),dataCenter.sWorkingProcedureName).group_by(dataCenter.sWorkingProcedureName).all():
        varDict = {
            'sWorkingProcedureName':var[1],
            'nCount':var[0]
        }
        cardNumberList.append(varDict)
    
    # 胚布库存增加
    for var in FPStoreLT():
        varDict = {
            'sWorkingProcedureName':'胚仓',
            'nCount':int(var['FPStoreQty'] / 1000)
        }
        cardNumberList.append(varDict)
    
    # 成品库存增加
    for var in STStoreSUM():
        varDict = {
            'sWorkingProcedureName':'成品仓' + var['sGrade'],
            'nCount':int(var['nStoreQty'] / 1000)
        }
        cardNumberList.append(varDict)
    return cardNumberList
    
# 计算WIP的百分比
def WIPPre():
    WIPPreList = []
    WIPSearch_var = WIPSearch()
    cardNumber_var = cardNumber()
    for var_ceiling in WIPSearch_var:
        for var_fact in cardNumber_var:
            if var_fact['sWorkingProcedureName'] == var_ceiling['sWorkingProcedureName']:
                factCount = var_fact['nCount']
                ceilingCount = int(var_ceiling['sCeiling'])
                sPre = int(round(factCount / ceilingCount,2) * 100)
                varDict = {
                    'sWorkingProcedureName':var_ceiling['sWorkingProcedureName'],
                    'sPre':str(sPre) + '%',
                    'sPre2':str(sPre) + '%',
                    'class_out':'',
                    'class_in':'progress-bar-info',
                    'sPreMath':str(factCount)+'/'+str(ceilingCount)
                }
                if sPre <= 100 and sPre > 80:
                    varDict['class_in'] = 'progress-bar-warning'
                elif sPre > 100:
                    varDict['class_out'] = 'progress-bar-warning'
                    varDict['class_in'] = 'progress-bar-danger'
                    if sPre / 100 < 2:
                        sPre = sPre - (int(sPre / 100) * 100)
                        varDict['sPre'] = str(sPre) + '%'
                    else:
                        sPre = 100
                        varDict['sPre'] = str(sPre) + '%'
                WIPPreList.append(varDict)
    print(WIPPreList)
    return WIPPreList


if __name__ == "__main__":
    FactoryFloorPlan('A001', 'A002', 'A003')
