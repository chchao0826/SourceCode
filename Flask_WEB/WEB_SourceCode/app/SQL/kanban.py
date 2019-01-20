# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
# from config import engine_236, engine_253
from app.config import engine_236, engine_253
from app.models import equipment, orgatex


base = declarative_base()
# 236
session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()
# 253
session_253 = sessionmaker(bind=engine_253)
ses_253 = session_253()

# 机台
def equipmentList(*args):
    equipmentList = []
    equipmentNo = ''.join(args)
    for var in ses_236.query(equipment).filter(and_(or_(equipment.bUsable == None, equipment.bUsable == 1),equipment.sEquipmentNo.like('%'+ equipmentNo +'%'))):
        var_dict = {
            'id':var.id,
            'sEquipmentNo':var.sEquipmentNo,
            'sEquipmentName':var.sEquipmentName,
            'bUsable':var.bUsable
        }
        equipmentList.append(var_dict)
    return equipmentList

# orgatex数值取出
def orgatexList(*args):
    EqList_1 = []
    Eq_list2 = []
    orgatex_now = []
    orgatex_next1 = []
    orgatex_next2 = []
    equipmentNo = ''.join(args)
    for var,var2 in ses_236.query(orgatex, equipment).filter(orgatex.iEquipmentID == equipment.id).filter(equipment.sEquipmentNo.like('%'+ equipmentNo +'%')).all():
        if var2.sEquipmentNo not in EqList_1:
            var_dict = {
                'id':var.id,
                'sEquipmentNo':var2.sEquipmentNo,
                'sCardNo':var.sCardNo,
                'sColorNo':var.sColorNo,
                'sMaterialNo':var.sMaterialNo,
                'sCustomerName':var.sCustomerName,
                'nFactInputQty':var.nFactInputQty,
                'tStartTime':var.tStartTime,
                'tPlanEndTime':var.tPlanEndTime,
                'sNowStatus':var.sNowStatus,
            }
            EqList_1.append(var2.sEquipmentNo)
            orgatex_now.append(var_dict)
        elif var2.sEquipmentNo not in Eq_list2:
            var_dict = {
                'id':var.id,
                'sEquipmentNo':var2.sEquipmentNo,
                'sCardNo':var.sCardNo,
                'sColorNo':var.sColorNo,
                'sMaterialNo':var.sMaterialNo,
                'sCustomerName':var.sCustomerName,
                'nFactInputQty':var.nFactInputQty,
            }
            Eq_list2.append(var2.sEquipmentNo)
            orgatex_next1.append(var_dict)
        else:
            for var_orgatex in orgatex_next1:
                if var_orgatex['sEquipmentNo'] == var2.sEquipmentNo:
                    var_dict = {
                        'id':var.id,
                        'sEquipmentNo':var2.sEquipmentNo,
                        'sCardNoNext1':var_orgatex['sCardNo'],
                        'sColorNoNext1':var_orgatex['sColorNo'],
                        'sMaterialNoNext1':var_orgatex['sMaterialNo'],
                        'sCustomerNameNext1':var_orgatex['sCustomerName'],
                        'nFactInputQtyNext1':var_orgatex['nFactInputQty'],
                        'sCardNoNext2':var.sCardNo,
                        'sColorNoNext2':var.sColorNo,
                        'sMaterialNoNext2':var.sMaterialNo,
                        'sCustomerNameNext2':var.sCustomerName,
                        'nFactInputQtyNext2':var.nFactInputQty,
                    }
            orgatex_next2.append(var_dict)
    return orgatex_now, orgatex_next2



if __name__ == '__main__':
    pass
