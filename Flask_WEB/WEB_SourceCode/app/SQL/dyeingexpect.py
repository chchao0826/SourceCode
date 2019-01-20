# -*-coding:utf-8-*-
# 染色预排信息表

from flask import render_template, Flask, request
from math import ceil
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
from app.config import engine_236, engine_253
from app.models import equipment, dyeingexpect
# from config import engine_236, engine_253
# from models import equipment, dyeingexpect

base = declarative_base()

session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()

# 查询所有未染色的工卡
def dyeingData(*args):
    dyeingData_list = []

    for var_args in args:
        for var_eq in var_args:
            # 判断用户输入的值
            # 判断输入的是否为机台号
            isEq = ses_236.query(dyeingexpect).filter(dyeingexpect.sEquipmentNo.like('%' + var_eq + '%') ).first()
            if isEq is not None:
                for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sEquipmentNo.like('%' + var_eq + '%') ).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)
                break
            # 判断输入的是否为卡号
            isCard = ses_236.query(dyeingexpect).filter(dyeingexpect.sCardNo.like('%' + var_eq + '%') ).first()
            if isCard is not None:
                # print('isCard')
                for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sCardNo.like('%' + var_eq + '%') ).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)
                    # print(dyeingData_list)
                break
            # 判断是否输入的为色号
            isColor = ses_236.query(dyeingexpect).filter(dyeingexpect.sColorNo.like('%' + var_eq + '%') ).first()
            if isColor is not None:
                for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sColorNo.like('%' + var_eq + '%') ).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)
                break
            # 判断输入的是否为客户
            isCust = ses_236.query(dyeingexpect).filter(dyeingexpect.sCustomerName.like('%' + var_eq + '%') ).first()
            if isCust is not None:
                for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sCustomerName.like('%' + var_eq + '%') ).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)
                break
            # 判断是否输入的为工段   
            isPDN = ses_236.query(dyeingexpect).filter(dyeingexpect.sWorkingProcedureName.like('%' + var_eq + '%') ).first()
            if isPDN :
                for var in ses_236.query(dyeingexpect).filter(dyeingexpect.sWorkingProcedureName.like('%' + var_eq + '%') ).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)
                break

        # 如果用户没有输入则返回所有大缸的数据 C/D
            if var_eq == 'all':
                for var in ses_236.query(dyeingexpect).filter(or_(dyeingexpect.sEquipmentNo.like('%'+'C'+'%'), dyeingexpect.sEquipmentNo.like('%'+'D'+'%'))).order_by(dyeingexpect.sEquipmentNo, dyeingexpect.tFactEndTime):
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
                        'tFactEndTime': var.tFactEndTime,
                        'tExpectTime': var.tExpectTime,
                        'sColor16': var.sColor16,
                    }
                    if var_dict not in dyeingData_list:
                        dyeingData_list.append(var_dict)        

    return dyeingData_list


# 对查询好的数据进行分页的处理
def pageData(page, *args):
    pageNumber = 17
    args_list = []
    page_max = 0
    ipage = int(page)
    dyeing_data = []
    if args == ():
        args_list = 'all'
    else:
        for var in args:
            args_list.append(var)
    # 调用上面的方法 进行变量的赋值            
    Data = dyeingData(args_list)
    # 数据长度
    Datalen = len(Data)

    i = 0 

    # 进行页数的拆分
    if Datalen >= pageNumber:
        page_max = ceil(Datalen / pageNumber)
        # 如果页码比最大页码要大，进行提示
        # print('ipage' + str(ipage))
        # print('page_max' + str(page_max))
        # print('Datalen' + str(Datalen))
        # print('pageNumber' + str(pageNumber))
        if ipage > page_max:
            return '已是最后一页'
        elif ipage < 1:
            return '已是第一页'
        else:
            startPage = (ipage - 1) * pageNumber
            endPage = ipage * pageNumber
            i = 0
            for var in Data:
                if i >= startPage and i <= endPage:
                    dyeing_data.append(var)
                i += 1
    else:
        for var in Data:
            dyeing_data.append(var)
            returnPage = 0
    # print(len(dyeing_data))
    returnPage = str(page_max)
    # print(dyeing_data)
    # print(returnPage)
    return dyeing_data, returnPage
    # return Data

# 机台添加
def equipmentNo(*args):
    equipmentList = []
    for var in args:
        for sEquipmentNo in ses_236.query(dyeingexpect).filter(dyeingexpect.sEquipmentNo.like('%'+ var +'%')).order_by(dyeingexpect.sEquipmentNo):
            equipmentDict = {
                'sEquipmentNo': sEquipmentNo.sEquipmentNo
            }
            if equipmentDict not in equipmentList :
                equipmentList.append(equipmentDict)
    # print(equipmentList)
    return equipmentList

# 机台信息更新
def updateEquipment(*args):
    for argsList in args:
        for var in argsList:
            ses_236.query(dyeingexpect).filter(dyeingexpect.id == var['id']).update({'sEquipmentNo' : var['sEquipmentNo']})
    return ses_236.commit(),ses_236.close()


if __name__ == '__main__':
    # var = pageData('1','A001','A002')
    # print(var)
    equipmentNo('C','D')
    # print(equipmentNo_var)

