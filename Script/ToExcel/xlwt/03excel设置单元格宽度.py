import xlwt
workbook = xlwt.Workbook()
worksheet = workbook.add_sheet('My sheet')
worksheet.write(0,0,'My cell Contents')
worksheet.col(0).width = 33333
worksheet.col(0).height = 33333
workbook.save('cell_width4.xls')