--ɾ��
Exec sp_dropserver [198.168.6.253]
Exec sp_droplinkedsrvlogin [198.168.6.253],Null

--�鿴����
Exec sp_helpserver

--���
EXEC sp_addlinkedserver
@server='198.168.6.253',--�����ʵķ�����������ϰ����ֱ��ʹ��Ŀ�������IP����ȡ�������磺JOY��
@srvproduct='',
@provider='SQLOLEDB',
@datasrc='198.168.6.253' --Ҫ���ʵķ�����


EXEC sp_addlinkedsrvlogin
'198.168.6.253', --�����ʵķ������������������sp_addlinkedserver��ʹ�ñ���JOY��������Ҳ��JOY��
'false',
NULL,
'fabrictrade', --�ʺ�
'fabric@2015' --����


SELECT  *FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].[psWorkFlowCard]