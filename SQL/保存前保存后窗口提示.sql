
DECLARE 
@iErrType INT ,--返回的类型 0 = 无提示,1 = 提示,2 = 报错 3 = 提示及确认
@sMessage NVARCHAR(MAX) -- 返回的信息
SELECT @iErrType = 1,@sMessage = '提示后可继续保存 '
