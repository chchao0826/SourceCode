import xlwt
workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('my sheet')
worksheet.write(0,0,5)
worksheet.write(0,1,2)
worksheet.write(1,0,xlwt.Formula('A1*B1'))
worksheet.write(1,1,xlwt.Formula('SUM(A1,B1)'))
workbook.save('Excel_workbook4.xls')
