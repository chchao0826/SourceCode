import xlwt
book = xlwt.Workbook(encoding='utf-8')
sheet = book.add_sheet('my sheet')
first_col = sheet.col(0)
sec_col = sheet.col(1)
first_col.width = 256 *20
tall_style = xlwt.easyxf('font:height 720;')
first_row = sheet.row(0)
first_row.set_style(tall_style)
book.save('with.xls')