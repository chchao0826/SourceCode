# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
from app.config import engine_236 
from app.models import dyeingexpect, equipment

# from config import engine_236 
# from models import dyeingexpect, equipment

base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()


# 机台
def PMEquipment():
    equipmentList = []
    for var in ses_236.query(equipment).filter(equipment.bIsPMKanBan == 1).order_by(equipment.sEquipmentNo):
        var_dict = {
            'id':var.id,
            'sEquipmentNo':var.sEquipmentNo,
            'sEquipmentName':var.sEquipmentName,
            'bUsable':var.bUsable
        }
        equipmentList.append(var_dict)
    return equipmentList

# 生管看板
def PMkanban(*args):
    PMkanban_list = []
    PMEquipment_var = PMEquipment()
    var_Number = 0

    if len(args) < 1:
        for var_eq in PMEquipment_var:
            for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sEquipmentNo == var_eq['sEquipmentNo']).order_by(dyeingexpect.tFactEndTime):
                var_dict = {
                    'id': var.id,
                    'sEquipmentNo': var.sEquipmentNo,
                    'sCardNo': var.sCardNo,
                    'sColorNo': var.sColorNo,
                    'sMaterialNo': var.sMaterialNo,
                    'sMaterialLot': var.sMaterialLot,
                    'tCardTime': var.tCardTime,
                    'nFactInputQty': var.nFactInputQty,
                    'sCustomerName': var.sCustomerName,
                    'sWorkingProcedureName': var.sWorkingProcedureName,
                    'sWorkingProcedureName_big': var.sWorkingProcedureName_big,
                    'tFactEndTime': var.tFactEndTime,
                    'tExpectTime': var.tExpectTime,
                    'sColor16': var.sColor16,
                }
                PMkanban_list.append(var_dict)
                var_Number += 1
    else:
        for wq in args:
            for var_eq in PMEquipment_var:
                for var in ses_236.query(dyeingexpect).filter(and_(dyeingexpect.sWorkingProcedureName_big == wq, dyeingexpect.sEquipmentNo == var_eq['sEquipmentNo'])).order_by(dyeingexpect.tFactEndTime):
                    var_dict = {
                        'id': var.id,
                        'sEquipmentNo': var.sEquipmentNo,
                        'sCardNo': var.sCardNo,
                        'sColorNo': var.sColorNo,
                        'sMaterialNo': var.sMaterialNo,
                        'sMaterialLot': var.sMaterialLot,
                        'tCardTime': var.tCardTime,
                        'nFactInputQty': var.nFactInputQty,
                        'sCustomerName': var.sCustomerName,
                        'sWorkingProcedureName': var.sWorkingProcedureName,
                        'sWorkingProcedureName_big': var.sWorkingProcedureName_big,
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    PMkanban_list.append(var_dict)
                    var_Number += 1
    
    # print(PMkanban_list)
    return PMkanban_list ,var_Number

# 工段区分机台的工卡数量
def cardCount(*args):
    cardCount = []
    PMEquipment_list = PMEquipment()
    for var_wp in args:
        PMkanban_var = PMkanban(var_wp)[0]
        for var_eq in PMEquipment_list :
            i = 0
            for var_card in PMkanban_var:
                if var_card['sEquipmentNo'] == var_eq['sEquipmentNo']:
                    i += 1
                var_dict = {
                    'sEquipmentNo' : var_eq['sEquipmentNo'],
                    'sWorkingProcedureName' : var_card['sWorkingProcedureName_big'],
                    'nCount' : i
                }
                    # print(var['id'])
            cardCount.append(var_dict)
    # print(cardCount)
    return cardCount


if __name__ == "__main__":
    # PMkanban()
    cardCount('配检布', '退卷', '水洗预定', '化验室', '染色')