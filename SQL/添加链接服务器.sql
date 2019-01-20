--删除
Exec sp_dropserver [198.168.6.253]
Exec sp_droplinkedsrvlogin [198.168.6.253],Null

--查看链接
Exec sp_helpserver

--添加
EXEC sp_addlinkedserver
@server='198.168.6.253',--被访问的服务器别名（习惯上直接使用目标服务器IP，或取个别名如：JOY）
@srvproduct='',
@provider='SQLOLEDB',
@datasrc='198.168.6.253' --要访问的服务器


EXEC sp_addlinkedsrvlogin
'198.168.6.253', --被访问的服务器别名（如果上面sp_addlinkedserver中使用别名JOY，则这里也是JOY）
'false',
NULL,
'fabrictrade', --帐号
'fabric@2015' --密码


SELECT  *FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].[psWorkFlowCard]