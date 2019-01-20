--CREATE TABLE pbCommonDataDyeingExpect(
--id INT PRIMARY KEY IDENTITY(1,1),
--sEquipmentNo NVARCHAR(30),
--sCardNo NVARCHAR(30),
--sColorNo NVARCHAR(30),
--sMaterialNo NVARCHAR(30),
--sMaterialLot NVARCHAR(30),
--tCardTime DATETIME,
--nFactInputQty DECIMAL(18,2),
--sCustomerName NVARCHAR(30),
--sWorkingProcedureName NVARCHAR(30),
--sWorkingProcedureName_big NVARCHAR(30),
--sWorkingProcedure_ALL NVARCHAR(30),
--tFactEndTime DATETIME,
--tExpectTime DATETIME,
--sColor16 NVARCHAR(30)
--)

--1. 判断在236表[pbCommonDataDyeingExpect]中工卡是否存在253[pbCommonDataExpectDataCenter]中
--   1. 如果不存在 则进行INSERT
--   2. 如果存在 则进行UPDATE
--2. 判断在253表[pbCommonDataExpectDataCenter]中的卡号是否存在236表[pbCommonDataDyeingExpect]中
--   1. 存在删除
--[pbCommonDataDyeingExpect]
--[pbCommonDataExpectDataCenter]

--1.1
INSERT INTO [DBO].[pbCommonDataDyeingExpect](
sEquipmentNo,sCardNo,sColorNo,sMaterialNo,sMaterialLot,tCardTime,nFactInputQty,sCustomerName
,sWorkingProcedureName,sWorkingProcedureName_big,sWorkingProcedure_ALL,tFactEndTime
)
SELECT sEquipmentPrepareNo,sCardNo,sColorNo,sMaterialNo,sMaterialLot,tCardTime,nFactInputQty,sCustomerName
,sWorkingProcedureName,sWorkingProcedureName_big,sWorkingProcedure_ALL,tFactEndTime
FROM [198.168.6.253].[HSWarpERP_NJYY].[DBO].[pbCommonDataExpectDataCenter] 
WHERE sCardNo NOT IN (SELECT sCardNo FROM [DBO].[pbCommonDataDyeingExpect])

--1.2
UPDATE [DBO].[pbCommonDataDyeingExpect]
SET sWorkingProcedureName = B.sWorkingProcedureName,
sWorkingProcedureName_big = B.sWorkingProcedureName_big,
sWorkingProcedure_ALL = B.sWorkingProcedure_ALL,
tFactEndTime = B.tFactEndTime
FROM [DBO].[pbCommonDataDyeingExpect] A
LEFT JOIN (
SELECT sEquipmentPrepareNo,sCardNo,sColorNo,sMaterialNo,sMaterialLot,tCardTime,nFactInputQty,sCustomerName
,sWorkingProcedureName,sWorkingProcedureName_big,sWorkingProcedure_ALL,tFactEndTime
FROM [198.168.6.253].[HSWarpERP_NJYY].[DBO].[pbCommonDataExpectDataCenter] 
WHERE sCardNo IN (SELECT sCardNo FROM [DBO].[pbCommonDataDyeingExpect])
) B ON A.sCardNo = B.sCardNo

--2.1
DELETE [DBO].[pbCommonDataDyeingExpect]
WHERE ID IN(
SELECT ID FROM  [DBO].[pbCommonDataDyeingExpect] A
WHERE sCardNo NOT IN (SELECT sCardNo FROM [198.168.6.253].[HSWarpERP_NJYY].[DBO].[pbCommonDataExpectDataCenter] )
)


SELECT *FROM [DBO].[pbCommonDataDyeingExpect]