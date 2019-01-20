import xlwt
workbook = xlwt.Workbook(encoding = 'utf-8')
worksheet = workbook.add_sheet('my WorkSheet')
worksheet.write(1,0, label = 'this is test')
workbook.save('Excel_test.xls')