# -*-coding:utf-8-*-
from flask import render_template, Flask, request
from sqlalchemy import or_, and_
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
from app.config import engine, connect
from app.sql.equipmentStatus import equipmentStatus
from app.sql.WorkingProcedureStatus import WorkingProcedureStatus
from app.sql.storeStatus import storeStatus


base = declarative_base()
# 236
session = sessionmaker(bind=engine)
ses = session()


# 机台状态
def emStatus():
    # 执行SQL语句转为List-详细
    TJ_eq = []
    Dye_eq1 = []
    Dye_eq2 = []
    Dye_eq3 = []
    Dye_eq4 = []
    Dye_eq5 = []
    Dye_eq6 = []
    TS_eq = []
    SX_eq = []
    DX_eq1 = []
    DX_eq2 = []
    DJ_eq = []
    YB_eq = []
    MM_eq = []
    PB_eq = []
    DB_eq = []
    FB_eq = []
    cursor = connect.cursor()
    # 创建一个游标对象,python里的sql语句都要通过cursor来执行
    cursor.execute(equipmentStatus)
    # 执行sql语句
    row = cursor.fetchone()
    # 读取查询结果
    while row:
        # print(row)
        dictVar = {
            'sEquipmentNo': row[1],
            'sEquipmentName': row[2],
            'sStatusColor': row[8],
        }
        if row[1] in ('LDR03', 'LDR02', 'LDR01'):
            TJ_eq.append(dictVar)
        elif row[1] in ('HQ03'):
            MM_eq.append(dictVar)
        elif row[1] in ('E027', 'E030', 'E029'):
            Dye_eq1.append(dictVar)
        elif row[1] in ('E028', 'E031', 'E026', 'E025'):
            Dye_eq2.append(dictVar)
        elif row[1] in ('A001', 'A002', 'A003', 'A004', 'A005', 'A006', 'C020'):
            Dye_eq3.append(dictVar)
        elif row[1] in ('B007', 'B008', 'B009', 'B010'):
            Dye_eq4.append(dictVar)
        elif row[1] in ('C015', 'C016', 'C017', 'C018', 'C019'):
            Dye_eq5.append(dictVar)
        elif row[1] in ('D021', 'D022', 'D023', 'D024'):
            Dye_eq6.append(dictVar)
        elif row[1] in ('HP01'):
            PB_eq.append(dictVar)
        elif row[1] in ('订边机'):
            DB_eq.append(dictVar)
        elif row[1] in ('LT03', 'LT02', 'LT01'):
            TS_eq.append(dictVar)
        elif row[1] in ('DR03'):
            FB_eq.append(dictVar)
        elif row[1] in ('LS02', 'LS01'):
            SX_eq.append(dictVar)
        elif row[1] in ('LB03', 'LB04', 'LB05'):
            DX_eq1.append(dictVar)
        elif row[1] in ('LB01', 'LB02'):
            DX_eq2.append(dictVar)
        elif row[1] in ('KJ04', 'KJ03', 'KJ02', 'KJ01'):
            DJ_eq.append(dictVar)
        elif row[1] in ('KI04', 'KI03', 'KI02', 'KI01'):
            YB_eq.append(dictVar)
        row = cursor.fetchone()
    cursor.close()

    print(DX_eq1)
    print(DX_eq2)
    # connect.close()
    return TJ_eq, MM_eq, Dye_eq1, Dye_eq2, Dye_eq3, Dye_eq4, Dye_eq5, Dye_eq6, PB_eq, DB_eq, TS_eq, FB_eq, SX_eq, DX_eq1, DX_eq2, DJ_eq, YB_eq

# 仓库状态
def StoreStatus():
    FPStore = []
    STAStore = []
    STCStore = []
    cursor = connect.cursor()
    cursor.execute(storeStatus)
    row = cursor.fetchone()
    sPerinner = ''
    sOutColor = ''
    sInnerColor = ''
    while row:

        if row[1] <= int(80):
            sPerinner = str(row[1]) + '%'
            sOutColor = 'progress-bar-success'
            sInnerColor = 'progress-bar-info'
        elif row[1] > int(80) and int(row[1]) <= int(100):
            sPerinner = str(row[1]) + '%'
            sOutColor = 'progress-bar-success'
            sInnerColor = 'progress-bar-warning'
        elif row[1] > int(100):
            sPerinner = '100%'
            sOutColor = 'progress-bar-warning'
            sInnerColor = 'progress-bar-danger'


        dictVar = {
            'sStoreName' : row[0],
            'sPerinner' : sPerinner,
            'sTDX' : row[2],
            'sOutColor' : sOutColor,
            'sInnerColor' : sInnerColor,
        }
        if row[0] == '胚仓':
            FPStore.append(dictVar)
        elif row[0] == '成品仓AB':
            STAStore.append(dictVar)
        elif row[0] == '成品仓C':
            STCStore.append(dictVar)
        row = cursor.fetchone()
    cursor.close()
    return FPStore, STAStore, STCStore


# 工段状态
def wpStatus():
    TJWip = []
    SXWip = []
    YDWip = []
    DyeWip = []
    CDWip = []
    BZWip = []
    cursor = connect.cursor()
    # 创建一个游标对象,python里的sql语句都要通过cursor来执行
    cursor.execute(WorkingProcedureStatus)
    # 执行sql语句
    row = cursor.fetchone()
    while row:
        sPerinner = ''
        sPerOut = '100%'
        sOutColor = ''
        sInnerColor = ''

        if row[1] <= int(80):
            sPerinner = str(row[1]) + '%'
            sOutColor = 'progress-bar-success'
            sInnerColor = 'progress-bar-info'
        elif row[1] > int(80) and int(row[1]) <= int(100):
            sPerinner = str(row[1]) + '%'
            sOutColor = 'progress-bar-success'
            sInnerColor = 'progress-bar-warning'
        elif row[1] > int(100):
            sPerinner = '100%'
            sOutColor = 'progress-bar-danger'
            sInnerColor = 'progress-bar-warning'

        dictVar = {
            'sWorkingProcedureName': row[0],
            'sPerinner': sPerinner,
            'sPerOut': sPerOut,
            'sOutColor': sOutColor,
            'sInnerColor': sInnerColor,
            'sTDX': row[2],
        }
        if row[0] == '退卷':
            TJWip.append(dictVar)
        elif row[0] == '水洗':
            SXWip.append(dictVar)
        elif row[0] == '预定':
            YDWip.append(dictVar)
        elif row[0] == '染色':
            DyeWip.append(dictVar)
        elif row[0] == '成定型':
            CDWip.append(dictVar)
        elif row[0] == '包装':
            BZWip.append(dictVar)            
        row = cursor.fetchone()

    cursor.close()
    return TJWip, SXWip, YDWip, DyeWip, CDWip, BZWip
    


if __name__ == '__main__':
    emStatus()
