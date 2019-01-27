SELECT C.sWorkingProcedureName,B.sEquipmentNo
,CASE WHEN DATEDIFF(MINUTE,A.tFactStartTime,GETDATE()) >= 80 THEN 0 ELSE 1 END AS bStatus
,ROW_NUMBER() OVER( PARTITION BY B.sEquipmentNo ORDER BY A.tFactStartTime DESC) AS nRank
,CONVERT(NVARCHAR(20),NULL) AS sColor
INTO #TEMP
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].ppTrackJob A
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].emEquipment B ON A.uemEquipmentGUID = B.uGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].pbWorkingProcedure C ON A.upbWorkingProcedureGUID = C.uGUID
WHERE DATEDIFF(HOUR,tFactStartTime,GETDATE()) < 8 AND A.uemEquipmentGUID IS NOT NULL

DELETE #TEMP
WHERE nRank <> 1 OR sWorkingProcedureName = '染色' OR sWorkingProcedureName = '進缸还原洗'
---以上除染色,包装,验布以外所有工段的目前情况

--染色
INSERT INTO #TEMP(sWorkingProcedureName,sEquipmentNo,bStatus,nRank)
SELECT '染色',sEquipmentNo,bStatus,nRank FROM(
select A.machine_no AS sEquipmentNo
,CASE WHEN DATEDIFF(HOUR,A.started,GETDATE()) > 8 THEN 0 ELSE 1 END AS bStatus
,ROW_NUMBER() OVER( PARTITION BY  A.machine_no ORDER BY A.started DESC) AS nRank
from  [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] A WITH(NOLOCK)  --所有在染資料
WHERE DATEDIFF(HOUR,A.started,GETDATE()) <= 24
) A
WHERE A.nRank = 1

----------------
------以下验布/打卷机台
--验布
INSERT INTO #TEMP(sWorkingProcedureName,sEquipmentNo,bStatus,nRank)
SELECT '验布',A.sEquipmentNo,A.bStatus,A.nRank FROM(
SELECT E.sEquipmentNo
,A.tInspectEndTime AS tFactStartTime
,CASE WHEN DATEDIFF(MINUTE,A.tInspectEndTime,GETDATE()) >=30 THEN 0 ELSE 1 END AS bStatus
,ROW_NUMBER() OVER(PARTITION BY E.sEquipmentNo ORDER BY A.tInspectEndTime DESC) AS nRank
FROM [198.168.6.253].[HSWarpERP_NJYY].dbo.qmInspectHdr A WITH ( NOLOCK )
INNER JOIN [198.168.6.253].[HSWarpERP_NJYY].dbo.emEquipment E WITH(NOLOCK) ON A.uemEquipmentGUID=E.uGUID
WHERE DATEDIFF(HOUR,tInspectEndTime,GETDATE()) <= 2
) A
WHERE nRank = 1

--包装
INSERT INTO #TEMP(sWorkingProcedureName,sEquipmentNo,bStatus,nRank)
SELECT '包装',A.sEquipmentNo,A.bStatus,A.nRank FROM(
SELECT E.sEquipmentNo
,C.sCardNo
,A.tCreateTime AS tFactStartTime
,CASE WHEN DATEDIFF(MINUTE,A.tCreateTime,GETDATE()) >=30 THEN 0 ELSE 1 END AS bStatus
,ROW_NUMBER() OVER(PARTITION BY E.sEquipmentNo ORDER BY A.tCreateTime DESC) AS nRank
FROM [198.168.6.253].[HSWarpERP_NJYY].dbo.qmInspectCut A WITH ( NOLOCK )
INNER JOIN [198.168.6.253].[HSWarpERP_NJYY].dbo.emEquipment E WITH(NOLOCK) ON A.uemEquipmentGUID=E.uGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].dbo.psWorkFlowCard C WITH(NOLOCK) ON C.uGUID = A.upsWorkFlowCardGUID
WHERE DATEDIFF(HOUR,A.tCreateTime,GETDATE()) <= 2
) A
WHERE nRank = 1

UPDATE #TEMP
SET sColor = CASE WHEN bStatus = 1 THEN '#3CB371' ELSE '#FFA500' END

SELECT
A.sEquipmentNo,A.sColor
FROM(
SELECT A.*,B.bStatus,B.sColor
FROM [YYLT].[dbo].[pbCommonDataEquipment] A
LEFT JOIN #TEMP B ON A.sEquipmentNo = B.sEquipmentNo
)A
ORDER BY 




DROP TABLE #TEMP