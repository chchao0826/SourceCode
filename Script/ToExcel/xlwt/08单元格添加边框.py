import xlwt
workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('my sheet')
borders = xlwt.Borders()
borders.left = xlwt.Borders.DASHED #虚线
borders.right = xlwt.Borders.DASHED
borders.top = xlwt.Borders.NO_LINE  #没有
borders.bottom = xlwt.Borders.THIN  #实线
borders.left_colour = 0x40
borders.right_colour = 0x40
borders.top_colour = 0x40
borders.bottom_colour = 0x40
style = xlwt.XFStyle()
style.borders = borders
worksheet.write(1, 1, 'Cell Contents', style)
workbook.save('EXCEL6.xls')