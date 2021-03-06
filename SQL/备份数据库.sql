USE [HSFabricTrade_NJYY]
GO
/****** Object:  StoredProcedure [dbo].[TradeBackUp]    Script Date: 2018-12-25 16:13:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[TradeBackUp]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Declare @strPsw varchar(50)

Declare @strUsr varchar(50)

Declare @strCmdShell varchar(300)

Declare @strDataBaseName varchar(20)

Declare @FullFileName Varchar(200)

Declare @FileFlag varchar(50)

Declare @FileFlag2 varchar(50)

Declare @ToFileName varchar(200)

Declare @ToFileName2 varchar(200)

Declare @SQLStr varchar(500)

Declare @SQLStr2 varchar(500)

Declare @SQLStr3 varchar(500)

Declare @FlagDel varchar(20)

Declare @SQLDelnet varchar(50)

Declare @SQLNetCon varchar(500)

Declare @SQLCopy varchar(500)

Declare @addDBName varchar(500)

Declare @delDBName varchar(500)

Declare @delDBName2 varchar(500)

Declare @ToFilePath varchar(500)

Declare @strDisk varchar(50)

 

Set @strDataBaseName='HSFabricTrade_NJYY' --填写数据库名称(如:Soondy)

Set @addDBName = @strDataBaseName+ '_db_' + CONVERT(varchar(100), GETDATE(), 12)
--备份的文件命名规则:yyyy-mm-dd hh:mi:ss(24小时制).bak

Set @delDBName=@strDataBaseName + '_db_' + CONVERT(varchar(100), GETDATE()-3, 12)  
--7天前的文件命名规则:yyyy-mm-dd.bak

Set @ToFilePath='H:\'+@addDBName+'.BAK'

 

Set @FlagDel='True'--填写True表示删除备份文件，填写False或其他字符表示保留该文件


Set @strUsr='Administrator'

Set @strPsw='lt@2013'

Set @strDisk='H:'

---------------'netuse H: \\192.168.1.199\111 /user:192.168.1.199\Administrator p@xxl'

Set @SQLNetCon='net use H: \\198.168.6.235\253ErpDBBackup /user:198.168.6.235\Administrator lt@2013'

--注意：现场应用时是win2003电脑2台都是，然后多次测试与网上查找原因发现，上面那语句不行（但在win7之间测的是没问题的，语句改成如下方式，可以了，不然一直提示错误1326用户名和密码错误）

--exec Master..xp_cmdshell 'net use H: \\192.168.1.199\111  xxl   /user:192.168.1.199\Administrator'--建立新映射，把199\111文件夹映射成本地H盘

 

--Set@SQLNetCon='net use '+@strDisk+' \\192.168.1.199\111/user:192.168.1.199\'+@strUsr+' p@'+@strPsw

Set @delDBName2 ='del ' + 'H:\'+ @delDBName+ '*.BAK'

exec Master..xp_cmdshell 'net use * /d /y' --删除旧链接

--execMaster..xp_cmdshell 'net use H: \\192.168.1.199\111/user:192.168.1.199\Administrator p@xxl'--建立新映射，把199\111文件夹映射成本地H盘

exec Master..xp_cmdshell  @SQLNetCon -- 'netuse H: \\192.168.1.199\111 /user:192.168.1.199\Administrator p@xxl'


--BackUpDataBase  @strDataBaseName  To Disk=  'H:\GYM20160115.BAK'  with init    --备份数据库

BackUp DataBase  @strDataBaseName  To Disk= @ToFilePath  with init   --备份数据库到映射的H盘

if (@FlagDel ='True')exec master.. xp_cmdshell @delDBName2--执行删除本地的备份临时文件

 
exec Master..xp_cmdshell 'net use * /d /y'--删除链接

END
