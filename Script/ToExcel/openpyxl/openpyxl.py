# -*- coding:utf-8 -*-
from config import engine_236, engine_253, connect
from sqlalchemy.orm import sessionmaker, relationship, query
from sql import execSql
# import pymssql
import datetime
import os
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Border, Side
from pandas.tseries.offsets import Day


# 执行SQL语句转为List-详细
def sqlToList():
    varList = []
    cursor = connect.cursor()
    # 创建一个游标对象,python里的sql语句都要通过cursor来执行
    cursor.execute(execSql)
    # 执行sql语句
    row = cursor.fetchone()
    # 读取查询结果
    while row:
        #循环读取所有结果
        varDict = {
            'sEquipmentgroupNo':row[0],
            'sEquipmentNo':row[1],
            'sCardNo':row[2],
            'nFactInputQty':row[3],
            'sCustomerName':row[4],
            'sProductGMWT':row[5],
            'sMaterialNo':row[6],
            'sLotColorNo':row[7],
            'sLotColorName':row[8],
            'tFactStartTime':row[9],
            'tFactEndTime':row[10],
            'sWorkingProcedureName':row[11],
            'sColorCatena':row[12],
            'sTempProcName':row[13],
            'sPrescriptionCardNoList':row[14],
            'sType':row[15],
            'sRepairReason':row[16],
        }
        varList.append(varDict)
        row = cursor.fetchone()
    cursor.close()
    # connect.close()
    return varList

# 获得日期格式 - 默认发送昨日的数据
def getDate():
    now_time = datetime.datetime.now()
    now = (now_time -1*Day()).strftime('%Y-%m-%d')
    return now

# 表头
def excelTitle():
    titleVar = (
        '类型',
        '机台',
        '卡号',
        '重量',
        '客户名称',
        '克重',
        '胚布编号',
        '色号',
        '色名',
        '开始时间',
        '结束时间',
        '工序',
        '色系',
        '升温程序',
        '操作时间',
        '加色',
        '原因'
    )
    return titleVar

# 判断是否为日期
def is_valid_date(strdate):
    try:
        if ":" in strdate:
            datetime.datetime.strptime(strdate, "%Y-%m-%d %H:%M:%S")
        else:
            datetime.datetime.strptime(strdate, "%Y-%m-%d")
        return True
    except:
        return False

def getChar(number):
    factor, moder = divmod(number, 26)
    modChar = chr(moder + 65)
    if factor != 0:
        modChar = getChar(factor - 1) + modChar
    return modChar


# 转化为EXCEL openpyxl
def pyxlToExcel():
    thisDate = getDate()
    tableName = '染色作业日报%s' % thisDate
    wb = Workbook()
    sheet = wb.active
    sheet.title = tableName
    sheet.append(excelTitle())

    # 单元格边框格式
    bd = Side(style='thin', color="000000")
    border = Border(left=bd, top=bd, right=bd, bottom=bd)

    listVar = sqlToList()
    a = 2
    b = 1

    # 遍历增加边框格式
    for i in listVar:
        for key in i:
            sheet.cell(row = a, column = b, value = i[key])
            sCell = getChar(b - 1) + str(a)
            sheet[sCell].border = border
            b += 1        
        b = 1
        a += 1

    # 列宽
    sheet.column_dimensions['C'].width = 15
    sheet.column_dimensions['E'].width = 16
    sheet.column_dimensions['G'].width = 12
    sheet.column_dimensions['H'].width = 15
    sheet.column_dimensions['I'].width = 20
    sheet.column_dimensions['J'].width = 23
    sheet.column_dimensions['K'].width = 23

    # 判断文件是否存在存在删除
    bIsFile = os.path.isfile("%s.xlsx" %tableName)
    if bIsFile:
        os.remove("%s.xlsx" %tableName)

    # 保存文件
    wb.save("%s.xlsx" %tableName)


# 报表格式整理
def mergeExcel():
    thisDate = getDate()
    tableName = '染色作业日报%s' % thisDate
    wb = load_workbook("%s.xlsx" %tableName)
    table = wb.get_sheet_by_name(tableName)
    # 最大行数
    rows = table.max_row
    # 最大列数
    cols = table.max_column
    # 边框格式
    bd = Side(style='thin', color="000000")
    border = Border(left=bd, top=bd, right=bd, bottom=bd)
    # 单元格格式
    align = Alignment(horizontal = "left", vertical = "center", wrap_text = True)

    nStart = 2
    nEnd = 1
    nLastEnd = 1
    sVarData = 'sVarData'
    for a in range(2, rows):
        data = table.cell(row = a, column = 1).value
        # 从第二个开始进行合并单元格
        if sVarData == 'sVarData':
            sVarData = data
        if data != sVarData:
            table.merge_cells('A'+ str(nStart)+':'+'A' + str(nEnd))
            scellName = 'A'+ str(nStart)
            table[scellName].alignment = align 
            nStart = a
            nLastEnd = nEnd + 1
            sVarData = data

        if a + 1 == rows:
            table.merge_cells('A'+ str(nLastEnd)+':'+'A' + str(a+1))
            scellName = 'A'+ str(nLastEnd)
            table[scellName].alignment = align 
        nEnd += 1

    nStart = 2
    nEnd = 1
    nLastEnd = 1
    sVarData = 'sVarData'
    for a in range(2, rows):
        data = table.cell(row = a, column = 2).value
        if sVarData == 'sVarData':
            sVarData = data
        if data != sVarData:
            table.merge_cells('B'+ str(nStart)+':'+'B' + str(nEnd))
            scellName = 'B'+ str(nStart)
            table[scellName].alignment = align
            nStart = a
            sVarData = data
            nLastEnd = nEnd + 1
        if a + 1 == rows:
            table.merge_cells('B'+ str(nLastEnd)+':'+'B' + str(a+1))
            scellName = 'B'+ str(nLastEnd)
            table[scellName].alignment = align
        nEnd += 1

    # 增加边框
    for i in range(1, rows + 1):
        for a in range(2):
            scellName = getChar(a) + str(i)
            # print(scellName)
            table[scellName].border = border
            # print(data)


    wb.save("%s.xlsx" %tableName)


if __name__ == "__main__":
    # print(sqlToListDetail())
    pyxlToExcel()
    # mergeExcel()
    # pyxlToExcel()
    mergeExcel()
    pass