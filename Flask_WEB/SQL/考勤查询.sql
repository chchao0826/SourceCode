--DROP TABLE [dbo].[pbCommonDataCheckIn]
--DROP TABLE [dbo].[pbCommonDataDepartment]
--DROP TABLE [dbo].[pbCommonDataEmployee]

--SELECT *FROM [dbo].[pbCommonDataCheckIn]
--SELECT *FROM [dbo].[pbCommonDataDepartment]
--SELECT *FROM [dbo].[pbCommonDataEmployee] A
--LEFT JOIN [dbo].[pbCommonDataDepartment] B ON A.ipbCommonDataDepartmentID = B.id

--UPDATE  [dbo].[pbCommonDataDepartment]
--SET bIsDayShift = 1
--WHERE sDeptName IN ('研发部','台干','生管课','成衣打样组','永续发展','人事行政部','检测中心','资讯部','控管部','仓库','技术部','总经理室','营二处','财务部','采购部','营三处','仓储（外包）','染厂厂务')


--SELECT *FROM [dbo].[pbCommonDataDepartment]


DECLARE @sMonth DATETIME
SET @sMonth = GETDATE()


SELECT A.id,C.sDeptName,B.sEmployeeName AS sEmployeeName
,A.tCheckTime AS tCheckTime
,ROW_NUMBER() OVER(PARTITION BY C.sDeptName,B.sEmployeeName,CONVERT(NVARCHAR(13),A.tCheckTime,120) ORDER BY C.sDeptName,B.sEmployeeName,A.tCheckTime) AS nRowNumber
INTO #TEMP
FROM [dbo].[pbCommonDataCheckIn] A
LEFT JOIN [dbo].[pbCommonDataEmployee] B ON A.iEmployeeID = B.id
LEFT JOIN [dbo].[pbCommonDataDepartment] C ON B.ipbCommonDataDepartmentID = C.id
WHERE CONVERT(NVARCHAR(7),A.tCheckTime,120) = CONVERT(NVARCHAR(7),@sMonth,120)
ORDER BY A.tCheckTime


DELETE #TEMP
WHERE nRowNumber > 1

SELECT id,sDeptName,sEmployeeName,tCheckTime
,ROW_NUMBER() OVER(PARTITION BY sDeptName, sEmployeeName ORDER BY tCheckTime) AS nRowNumber
INTO #TEMP2
FROM #TEMP






SELECT A.*
FROM (
SELECT A.sDeptName,A.sEmployeeName,A.tCheckTime AS tCheckTimeIN,B.tCheckTime AS tCheckTimeOUT
FROM #TEMP2 A
LEFT JOIN #TEMP2 B ON A.sDeptName = B.sDeptName AND A.sEmployeeName = B.sEmployeeName AND A.nRowNumber = B.nRowNumber - 1
WHERE A.nRowNumber % 2 <> 0
) A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND B.bIsDayShift = 1







--SELECT A.sDeptName,B.tStartTime,ISNULL(B.toverworktime,B.tEndTime) AS tEndTime
--,C.sEmployeeNameCN
--FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourHdr] A
--LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourDtl] B ON A.uGUID = B.upbCommonDataworkhourHdrGUID
--LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourEmployee] C ON B.uGUID = C.upbCommonDataworkhourDtlGUID
--WHERE CONVERT(NVARCHAR(7),B.tStartTime,120) = CONVERT(NVARCHAR(7),@sMonth,120)



DROP TABLE #TEMP
DROP TABLE #TEMP2

