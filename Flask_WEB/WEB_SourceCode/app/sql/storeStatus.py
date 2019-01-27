storeStatus = "CREATE TABLE #TEMP(sType NVARCHAR(30) \
,nStockQty DECIMAL(18,2)) \
INSERT INTO #TEMP(sType,nStockQty) \
SELECT '胚仓' AS sType, SUM(nStockQty) / 1000 AS nStockQty \
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].vwmmFPInStore \
WHERE ISNULL(nStockQty,0) <> 0 AND sLocation NOT LIKE '%常运%' \
INSERT INTO #TEMP(sType,nStockQty) \
SELECT *FROM( \
SELECT '成品仓' + CASE WHEN sGrade IN ('A','B') THEN 'AB' \
WHEN sGrade IN ('C','C1') THEN 'C'  END  AS sType \
,SUM(nStockQty) / 1000 AS nStockQty \
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].vwmmSTInStore A \
WHERE ISNULL(nStockQty,0) <> 0 \
GROUP BY '成品仓' + CASE WHEN sGrade IN ('A','B') THEN 'AB' \
WHEN sGrade IN ('C','C1') THEN 'C'  END ) A \
WHERE sType IS NOT NULL \
SELECT A.sType \
,CONVERT(INT,A.nStockQty / B.nUpper * 100) AS nPer \
,CONVERT(NVARCHAR(50),CONVERT(INT,A.nStockQty)) + '/' + CONVERT(NVARCHAR(50),B.nUpper) AS nTDX \
FROM #TEMP A \
JOIN [dbo].[pbCommonDataWorkingProcedure] B ON A.sType = B.sWorkingProcedureName \
DROP TABLE #TEMP"