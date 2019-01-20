import xlwt
workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('my sheet')
alignment = xlwt.Alignment()
alignment.horz = xlwt.Alignment.HORZ_CENTER
alignment.vert = xlwt.Alignment.VERT_CENTER
style = xlwt.XFStyle()
style.alignment = alignment
worksheet.write(0, 0, 'Cell contents', style)
worksheet.write(1, 0, '2', style)
workbook.save('Excel4.xls')