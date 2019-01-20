from model import department_search
from datetime import datetime
import xlwt  
import os

def CreateExcel(*args, **kwarges):
    workbook = xlwt.Workbook()
    worksheet1 = workbook.add_sheet('昨日')
    worksheet2 = workbook.add_sheet('今日')
    style = xlwt.XFStyle()
    borders = xlwt.Borders()
    borders.bottom = xlwt.Borders.THIN
    style.borders = borders
    Date = datetime.now().date()
    tableName = str(Date.year) + str(Date.month) + str(Date.day)
    print(tableName)
    for i in range(len(args)):
        worksheet1.write(0, i, args[i], style)
        print(args[i])
    a = 1
    b = 0
    for var in department_search():
        b = 0
        for i in var:
            worksheet1.write(a, b, var[i], style)
            b += 1
        a += 1

    for i in range(len(args)):
        worksheet2.write(0, i, args[i], style)
        print(args[i])
    a = 1
    b = 0
    for var in department_search():
        b = 0
        for i in var:
            worksheet2.write(a, b, var[i], style)
            b += 1
        a += 1

    bIsFile = os.path.isfile("%s.xls" %tableName)
    if bIsFile:
        os.remove("%s.xls" %tableName)
    workbook.save('%s.xls' %tableName)

if __name__ == '__main__':
    CreateExcel = CreateExcel('id','部门编号','部门名称','上级部门','人数')
    print(CreateExcel)
