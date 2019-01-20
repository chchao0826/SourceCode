#-*- coding:UTF-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.header import Header

mail_host = 'smtp.czlingtai.cn'
mail_user = 'it2@czlingtai.cn'
mail_pass = '******'

sender = 'it2@czlingtai.cn'
receivers = ['it2@czlingtai.cn']

message = MIMEText('Python 邮件发送测试....', 'plain', 'utf-8')
message['From'] = Header('教程')
message['To'] = Header('test')

subject = 'Python SMTP 邮件测试'
message['Subject'] = Header(subject, 'utf-8')

try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print('邮件发送成功')
except smtplib.SMTPException:
    print('Error')
