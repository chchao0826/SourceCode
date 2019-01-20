import xlwt
import datetime

workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('my sheet')
style = xlwt.XFStyle()
style.num_format_str = 'M/D/YY'
worksheet.write(0,0,datetime.datetime.now(),style)
workbook.save('excel_workbook3.xls')