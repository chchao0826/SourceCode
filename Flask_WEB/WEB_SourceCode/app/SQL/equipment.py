# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
# from config import engine_236, engine_253
from app.config import engine_236, engine_253
from app.models import equipment, equipmentStatus

# from config import engine_236, engine_253
# from models import equipment, equipmentStatus

base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()

# 机台按部门列表
def equipmentList(*args):
    equipment_list = []
    for var_work in args:
        for var in ses_236.query(equipmentStatus.ipbCommonDataEquipmentID, equipmentStatus.sStatusColor, equipment.id, equipment.sEquipmentNo, equipment.sEquipmentName, equipmentStatus.sStatus, equipment.bUsable, equipment.nRowNumber, equipment.sWorkingProcedureName)\
            .filter(and_(equipmentStatus.ipbCommonDataEquipmentID == equipment.id, equipment.sWorkingProcedureName == var_work)).join(equipment, equipment.id == equipmentStatus.ipbCommonDataEquipmentID):
            bUsable = ''
            if var.bUsable == 1:
                bUsable = 'checked'
            varDict = {
                'sEquipmentNo':var.sEquipmentNo,
                'sEquipmentName':var.sEquipmentName,
                'sWorkingProcedureName':var.sWorkingProcedureName,
                'bUsable':bUsable,
                'nRowNumber':var.nRowNumber,
                'sStatus':var.sStatus,
                'sStatusColor':var.sStatusColor
            }
            equipment_list.append(varDict)
    # print(equipment_list)
    return equipment_list

# 机台按区域列表
def equipmentGroupList(*args):
    equipment_list = []
    for var_work in args:
        for var in ses_236.query(equipmentStatus.ipbCommonDataEquipmentID, equipmentStatus.sStatusColor, equipment.id, equipment.sEquipmentNo, equipment.sEquipmentName, equipmentStatus.sStatus, equipment.bUsable, equipment.nRowNumber, equipment.sWorkingProcedureName)\
            .filter(and_(equipmentStatus.ipbCommonDataEquipmentID == equipment.id, equipment.sEquipmentNo.like('%'+ var_work +'%'))).join(equipment, equipment.id == equipmentStatus.ipbCommonDataEquipmentID):
            bUsable = ''
            if var.bUsable == 1:
                bUsable = 'checked'
            varDict = {
                'sEquipmentNo':var.sEquipmentNo,
                'sEquipmentName':var.sEquipmentName,
                'sWorkingProcedureName':var.sWorkingProcedureName,
                'bUsable':bUsable,
                'nRowNumber':var.nRowNumber,
                'sStatus':var.sStatus,
                'sStatusColor':var.sStatusColor
            }
            equipment_list.append(varDict)
    print(equipment_list)
    return equipment_list




# 机台中的部门      
def equipmentWP(*args):
    sWorkingProcedureNameList = []
    i = 0
    sWorkingProcedureNameVar = ''
    for var in ses_236.query(equipment).order_by(equipment.id):
        var_dict = {
            'id': i,
            'sWorkingProcedureName': var.sWorkingProcedureName
        }
        i += 1
        if var.sWorkingProcedureName != sWorkingProcedureNameVar:
            sWorkingProcedureNameVar = var.sWorkingProcedureName
            sWorkingProcedureNameList.append(var_dict)

    return sWorkingProcedureNameList

def equipmentUpdate(*args):
    print('---' * 15)
    for argsList in args:
        for var in argsList:
            if var['bUsable'] == 'off':
                var['bUsable'] = True
            else:
                var['bUsable'] = False
            var['sEquipmentNo'] = var['sEquipmentNo'].strip()
            
            ses_236.query(equipment).filter(equipment.sEquipmentNo == var['sEquipmentNo']).update({'bUsable' : var['bUsable']})
            ses_236.query(equipment).filter(equipment.sEquipmentNo == var['sEquipmentNo']).update({'nRowNumber' : var['nRowNumber']})
            ses_236.commit() 
            ses_236.close()

    return ses_236.commit(), ses_236.close()



