import xlwt
workbook = xlwt.Workbook(encoding='ascii')
worksheet = workbook.add_sheet('My WorkSheet')
style = xlwt.XFStyle() #创建样式表
font = xlwt.Font()      #创建字体
font.name = 'Time New Roman' #字体格式
font.bold = True    #加粗
font.underline = True   #下划线
font.italic = True  #斜体
style.font = font   #赋予样式
# worksheet.write(0, 0, label = 'Unformatted value')
# worksheet.write(1, 0, label = 'Formatted value', style)
worksheet.write(0, 0, 'Unformatted value')  #不带样式的写入
worksheet.write(1, 0, 'Formatted value', style) #带样式的写入
workbook.save('Excel_workBook2.xls')    #保存文件