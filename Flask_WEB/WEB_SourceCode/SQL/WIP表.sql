--CREATE TABLE pbCommonDataWorkingProcedure(
--id INT primary key IDENTITY(1,1)
--,sWorkingProcedureName NVARCHAR(30)
--,nUpper DECIMAL(18,2)
--)


SELECT A.sCardNo,B.tFactStartTime,B.tFactEndTime
,CASE WHEN C.sWorkingProcedureName IN ('半成品套色','成品套色','打色','復色') THEN '化验室'
WHEN C.sWorkingProcedureName IN ('包裝') THEN '包装'
WHEN C.sWorkingProcedureName IN ('成定型') THEN '成定型'
WHEN C.sWorkingProcedureName IN ('進缸还原洗','剖布','染色','訂邊','缸練','改染','试修','洗缸','剥色','進缸修','皂洗') THEN '染色'
WHEN C.sWorkingProcedureName IN ('配檢布','配檢+退卷','配檢+定型','配檢+水洗') THEN '配检布'
WHEN C.sWorkingProcedureName IN ('批色','驗布') THEN '验布'
WHEN C.sWorkingProcedureName IN ('水洗') THEN '水洗'
WHEN C.sWorkingProcedureName IN ('预定','精煉','烘干','低溫預定','大定') THEN '预定'
WHEN C.sWorkingProcedureName IN ('脫水','剖布+展布','展布','脫水+開幅','脫水+展布') THEN '脱水展布'
WHEN C.sWorkingProcedureName IN ('磨毛','雙面磨毛') THEN '磨毛'
WHEN C.sWorkingProcedureName IN ('成品繳庫') THEN '成品缴库'
WHEN C.sWorkingProcedureName IN ('退卷') THEN '退卷' ELSE NULL END AS sWorkingProcedureName
,A.tCardTime
,ROW_NUMBER() OVER(PARTITION BY sCardNo ORDER BY  B.iOrderProcedure) AS nRowNumber
INTO #TEMP
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].psWorkFlowCard A
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].ppTrackJob B ON A.uGUID = B.upsWorkFlowCardGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].pbWorkingProcedure C ON C.uGUID = B.upbWorkingProcedureGUID
JOIN [198.168.6.253].[HSWarpERP_NJYY].dbo.vwsdOrder E WITH(NOLOCK) ON E.usdOrderLotGUID = A.usdOrderLotGUID
WHERE B.tFactEndTime IS NULL AND A.sStatus = '正常' AND A.bUsable = 1 AND DATEDIFF(MONTH,tCardTime,GETDATE()) <= 6
AND E.sOrderType IN ('D','K','G','LTKJ','L','I','IL','S','J')
DELETE  #TEMP WHERE nRowNumber > 1 OR sWorkingProcedureName IS NULL
SELECT sWorkingProcedureName,COUNT(*) AS nCount
INTO #TEMP1
FROM #TEMP A
GROUP BY sWorkingProcedureName
SELECT A.sWorkingProcedureName
,CONVERT(DECIMAL(18,2),B.nCount/A.nUpper *100) AS nPre
,CONVERT(NVARCHAR(10),B.nCount) +'/' +CONVERT(NVARCHAR(10),A.nUpper) AS sTDX
FROM [dbo].[pbCommonDataWorkingProcedure] A
LEFT JOIN #TEMP1 B ON A.sWorkingProcedureName = B.sWorkingProcedureName
DROP TABLE #TEMP
DROP TABLE #TEMP1



