# -*- coding:utf-8 -*-
from config import engine_236, engine_253, connect
from sqlalchemy.orm import sessionmaker, relationship, query
from EnerySearch import sql
from EneryGroup import sqlGroup
import pymssql
import datetime
import xlwt
import os
import time
from pandas.tseries.offsets import Day

# 执行SQL语句转为List-详细
def sqlToListDetail():
    varList = []
    cursor = connect.cursor()   
    # 创建一个游标对象,python里的sql语句都要通过cursor来执行
    cursor.execute(sql)   
    # 执行sql语句
    row = cursor.fetchone()  
    # 读取查询结果
    while row:              
        #循环读取所有结果
        varDict = {
            'dReportDate':row[0],
            'nDiffPrintingWater':row[2],
            'nDiffPrintingCleanWater':row[7],
            'nDiffPrintingSoftWater':row[13],
            'nDiffPrintingHotWater':row[14],
            'nDiffRefineMachineWater':row[3],
            'nDiffFinishWater':row[4],
            'nDiffLifeWater':row[5],
            'nDiffOfficeWater':row[30],
            'nDiffsDyeingWater':row[6],
            'nDiffDyeingHotWater':row[8],
            'nDiffDyeingWater':row[9],
            'nDiffHotWater':row[10],
            'nDiffColdWater':row[11],
            'sColdWaterPre':row[12],
            'nDiffTotalWater':row[15],
            'nDiffDirtyWater':row[16],
            'sRemark':row[1],
            'nDiffSteam':row[17],
            'nDiffPrintingSteam':row[18],
            'nDiffMachine':row[19],
            'nDiffPrintingGas':row[20],
            'nDiffTotalElectricity':row[21],
            'nDiffPrintingElectricity':row[22],
            'nDiffWeaveElectricity':row[23],
            'nDiffRefineMachineElectricity':row[24],
            'nDiffFinish1Electricity':row[25],
            'nDyeingElectricity':row[26],
            'nDiffLabElectricity':row[28],
            'nDiffWaterTreatmentElectricity':row[27],
            'nOiLWater':row[29],
            'nDiffCoolingTower1':row[31],
            
            # 'nDiffPrintingWater_BGCOLOR':row[33],
            # 'nDiffRefineMachineWater_BGCOLOR':row[34],
            # 'nDiffFinishWater_BGCOLOR':row[35],
            # 'nDiffLifeWater_BGCOLOR':row[36],
            # 'nDiffsDyeingWater_BGCOLOR':row[37],
            # 'nDiffTotalWater_BGCOLOR':row[38],
            # 'nDiffDirtyWater_BGCOLOR':row[39],
            # 'nDiffOfficeWater_BGCOLOR':row[40],
            # 'nDiffCoolingTower1_BGCOLOR':row[41],
            # 'sRemark_BGCOLOR':row[42],
        }
        varList.append(varDict)
        # print(varDict)
        # 打印结果
        row = cursor.fetchone()
    
    cursor.close()
    # connect.close()
    return varList

# 执行SQL语句转为List-汇总
def sqlToListGroup():
    varList = []
    cursor = connect.cursor()
    cursor.execute(sqlGroup)
    row = cursor.fetchone()
    while row:
        varDict = {
            'ReportDate':row[0],
            'nDiffPrintingWater':row[1],
            'nDiffRefineMachineWater':row[2],
            'nDiffFinishWater':row[3],
            'nDiffLifeWater':row[4],
            'nDiffsDyeingWater':row[5],
            'nDiffPrintingCleanWater':row[6],
            'nDiffDyeingHotWater':row[7],
            'nDiffDyeingWater':row[8],
            'nDiffHotWater':row[9],
            'nDiffColdWater':row[10],
            'nDiffPrintingSoftWater':row[11],
            'nDiffPrintingHotWater':row[12],
            'nDiffOfficeWater':row[13],
            'nDiffCoolingTower1':row[14],
            'nDiffTotalWater':row[15],
            'nDiffDirtyWater':row[16],
            'nDiffSteam':row[17],
            'nDiffPrintingSteam':row[18],
            'nDiffMachine':row[19],
            'nDiffPrintingGas':row[20],
            'nDiffTotalElectricity':row[21],
            'nDiffPrintingElectricity':row[22],
            'nDiffWeaveElectricity':row[23],
            'nDiffRefineMachineElectricity':row[24],'nDiffFinish1Electricity':row[25],
            'nDyeingElectricity':row[26],
            'nDiffWaterTreatmentElectricity':row[27],
            'nDiffLabElectricity':row[28],
            'nDiffWarpingElectricity':row[29],
            'nOiLWater':row[30]
        }
        varList.append(varDict)
        row = cursor.fetchone()
    
    
    cursor.close()
    return varList

# 获得日期格式
def getDate():
    now_time = datetime.datetime.now()
    now = (now_time -1*Day()).strftime('%Y-%m-%d')
    return now

# 报表的第一行表头数据
def excelTitleDetail():
    titleVar = ('日期',
    '印花总用水',
    '印花清水(吨)',
    '印花软水',
    '印花热水',
    '水洗用水(吨)',
    '定型用水(吨)',
    '生活用水(吨)',
    '办公楼用水',
    '染色用水(吨)',
    '染色用水(新)',
    '染色热水(吨)',
    '热水(吨)',
    '总回收总热水',
    '热水回收率',
    '总用水',
    '污水',
    '备注',
    '蒸气',
    '印花蒸气',
    '天然气',
    '印花天然气',
    '总用电',
    '印花用电',
    '织厂用电',
    '整经用电'
    '水洗1用电',
    '定型1用电',
    '染色用电',
    '化验室用电',
    '染厂级印花公共用电',
    '2号静电除尘用水',
    '1号静电除尘用水',
    )
    return titleVar

# sheet2表头
def excelTitleGroup():
    titleVar = (
        '日期',
        '印花总用水',
        '水洗用水',
        '定型用水',
        '生活用水',
        '染色用水',
        '印花清水',
        '染色热水',
        '染色用水',
        '热水',
        '总回收热水',
        '印花软水',
        '印花热水',
        '办公楼用水',
        '1号静电除尘用水',
        '总用水',
        '污水',
        '蒸气',
        '印花蒸气',
        '天然气',
        '印花天然气',
        '总用电',
        '印花用电',
        '织厂用电',
        '水洗用电',
        '定型1用电',
        '染色用电',
        '染厂及印花用电',
        '化验室用电',
        '整经用电',
        '2号静电除尘用电'
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

# 转化为EXCEL
def toExcel():
    thisDate = getDate()
    workbook = xlwt.Workbook()
    worksheet1 = workbook.add_sheet('水电气日报表%s' %thisDate)
    worksheet2 = workbook.add_sheet('月报')
    borders = xlwt.Borders()
    borders.bottom = xlwt.Borders.THIN
    borders.left = xlwt.Borders.THIN
    borders.right = xlwt.Borders.THIN
    # 普通格式
    style = xlwt.XFStyle()
    style.borders = borders
    # 日期格式
    datestyle = xlwt.XFStyle()
    datestyle.num_format_str = 'yyyy-mm-dd'
    datestyle.borders = borders
    #设置蓝色背景
    rain = xlwt.Pattern()
    rain.pattern = xlwt.Pattern.SOLID_PATTERN
    rain.pattern_fore_colour = 17
    rainStyle = xlwt.XFStyle()
    rainStyle.pattern = rain
    # 标题栏
    title = xlwt.Pattern()
    title.pattern = xlwt.Pattern.SOLID_PATTERN
    title.pattern_fore_colour = 23
    titleStyle = xlwt.XFStyle()
    titleStyle.pattern = title

    tableName = '水电气日报表%s' % thisDate
    # print(tableName)
    excelTitleDetailVar = excelTitleDetail()
    for i in range(len(excelTitleDetailVar)):
        worksheet1.write(0, i, excelTitleDetailVar[i], style)
        # worksheet1.col(0).height = 10000
        # print(excelTitleDetailVar[i])
    listVar = sqlToListDetail()
    a = 1
    b = 0
    for i in listVar:
        b = 0
        for key in i:
            # print(key+':'+str(i[key]))
            # print(i[key])
            # if is_valid_date(i[key]) == True:
            if type(i[key]) == type(datetime.datetime.now()):
                worksheet1.write(a, b, i[key], datestyle)
                worksheet1.col(b).width = 3000
            elif i[key] == '下雨':
                worksheet1.write(a, b, i[key], rainStyle)
            else:
                worksheet1.write(a, b, i[key], style)
            b += 1
        a += 1
    # 月报表
    excelTitleGroupVar = excelTitleGroup()
    for i in range(len(excelTitleGroupVar)):
        worksheet2.write(0, i, excelTitleGroupVar[i], style)
        # worksheet1.col(0).height = 10000
    sqlToListGroupVar = sqlToListGroup()
    a = 1
    b = 0
    for i in sqlToListGroupVar:
        b = 0
        for key in i:
            if type(i[key]) == type(datetime.datetime.now()):
                worksheet2.write(a, b, i[key])
                worksheet2.col(b).width = 3000
            else:
                worksheet2.write(a, b, i[key], style)
            b += 1
        a += 1

    bIsFile = os.path.isfile("%s.xls" %tableName)
    if bIsFile:
        os.remove("%s.xls" %tableName)
    workbook.save("%s.xls" %tableName)
    
    
    connect.close()    
    return '成功'

if __name__ == "__main__":
    # print(sqlToListDetail())
    print(toExcel())
