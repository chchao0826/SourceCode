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

--1. �ж���236��[pbCommonDataDyeingExpect]�й����Ƿ����253[pbCommonDataExpectDataCenter]��
--   1. ��������� �����INSERT
--   2. ������� �����UPDATE
--2. �ж���253��[pbCommonDataExpectDataCenter]�еĿ����Ƿ����236��[pbCommonDataDyeingExpect]��
--   1. ����ɾ��
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