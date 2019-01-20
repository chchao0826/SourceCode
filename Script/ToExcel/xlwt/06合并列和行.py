import xlwt
workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('my sheet')
worksheet.write_merge(0, 0, 0, 3, 'First Merge')
font = xlwt.Font()
font.bold = True
style = xlwt.XFStyle()
style.font = font
worksheet.write_merge(2, 3, 0, 3, 'Second Merge', style)
workbook.save('Excel_workbook8.xls')