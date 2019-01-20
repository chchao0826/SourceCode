import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header

mail_host = 'smtp.czlingtai.cn'
mail_user = 'it2@czlingtai.cn'
mail_pass = '******'

sender = 'it2@czlingtai.cn'
receivers = ['it2@czlingtai.cn']

receivers_var = [str(i) for i in receivers]
receiver = ','.join(receivers_var)

message = MIMEMultipart()
message['From'] = Header('%s' %sender)
message['To'] = Header('%s' %receiver)
subject = '自动发送邮件-每日考勤'
message['subject'] = Header(subject, 'utf-8')

message.attach(MIMEText('附件为今天九点考勤情况,请查阅','plain', 'utf-8'))

att = MIMEText(open('201895.xls', 'rb').read(), 'base64', 'utf-8')
att['Content-Type'] = 'application/octet-stream'
att['Content-Disposition'] = 'attachment; filename="201895.xls"'

att2 = MIMEText(open('201894.xls', 'rb').read(), 'base64', 'utf-8')
att2['Content-Type'] = 'application/octet-stream'
att2['Content-Disposition'] = 'attachment; filename="201894.xls"'


message.attach(att)
message.attach(att2)

try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print('邮件发送成功')
except smtplib.SMTPException:
    print('Error')

