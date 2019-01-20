CREATE TABLE pbCommonDataRecipeRemind(
uGUID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT(NEWID())
,sBillNo NVARCHAR(20)
,sCteator NVARCHAR(30)
,tCreateTime DATETIME
,sUpdateMan NVARCHAR(30)
,tUpdateTime DATETIME
,sAuditMan NVARCHAR(30)
,tAuditTime DATETIME
,sConfirmMan NVARCHAR(30)
,tConfirmTime DATETIME
,iBillStatus INT
,iBillType INT
,bUsable BIT
,sStatus NVARCHAR(20)

)
SELECT *FROM pbCommonDataTPSHdr