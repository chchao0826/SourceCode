import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
import datetime
from pandas.tseries.offsets import Day
import os
from toExcel import toExcel,mergeExcel

# 获得日期格式
def getDate():
    now_time = datetime.datetime.now()
    now = (now_time -1*Day()).strftime('%Y-%m-%d')
    return now

# 获得昨日日期
def getLastDate():
    now_time = datetime.datetime.now()
    lastday = (now_time -2*Day()).strftime('%Y-%m-%d')
    print(lastday)
    return lastday

# 删除昨日报表
def deleteLastTable():
    lastTableName = '水电气日报表%s' %getLastDate()
    isLastFile = os.path.isfile("%s.xls" %lastTableName)
    if isLastFile:
        os.remove("%s.xls" %lastTableName)

# 邮件服务器
def emailServer():
    mail_host = 'smtp.czlingtai.cn'
    mail_user = 'it2@czlingtai.cn'
    mail_pass = '******'
    varDict = {
        'mail_host':mail_host,
        'mail_user':mail_user,
        'mail_pass':mail_pass
    }
    return varDict

# 发送的信息
def emailMessage(att):
    nowDate = getDate()
    message = MIMEMultipart()
    message['From'] = Header('%s' %sender)
    message['To'] = Header('%s' %receiver)
    subject = '自动发送邮件-%s每日水电气 ' %nowDate
    message['subject'] = Header(subject, 'utf-8')
    message.attach(MIMEText('附件为%s水电气日报,请查阅' %nowDate,'plain', 'utf-8'))
    message.attach(att)
    return message

# 发送的文件
def sendFile():
    nowDate = getDate()
    tableName = '水电气日报表%s' %nowDate
    att = MIMEText(open('%s.xls' %tableName, 'rb').read(), 'base64', 'utf-8')
    att['Content-Type'] = 'application/octet-stream'
    att['Content-Disposition'] = 'attachment; filename="%s.xls"' %nowDate
    return att
# 运行文件
if __name__ == '__main__':
    toExcel()
    mergeExcel()
    deleteLastTable()
    sender = 'it2@czlingtai.cn'
    receivers = ['it2@czlingtai.cn']
    receivers_var = [str(i) for i in receivers]
    receiver = ','.join(receivers_var)
    emailServerVar = emailServer()
    print(emailServerVar['mail_host'])
    att = sendFile()
    message = emailMessage(att)
    try:
        smtpObj = smtplib.SMTP()
        smtpObj.connect(emailServerVar['mail_host'], 25)
        smtpObj.login(emailServerVar['mail_user'], emailServerVar['mail_pass'])
        smtpObj.sendmail(sender, receivers, message.as_string())
        print('邮件发送成功')
    except smtplib.SMTPException:
        print('Error')

