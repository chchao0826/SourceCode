SELECT CASE WHEN DATEDIFF(dd, A.tStoreInTime, GETDATE())>360 THEN 360
WHEN DATEDIFF(dd, A.tStoreInTime, GETDATE())>180 THEN 180
WHEN DATEDIFF(dd, A.tStoreInTime, GETDATE())>90 THEN 90   WHEN DATEDIFF(dd, A.tStoreInTime, GETDATE())>30 THEN 30  END as nRetentionTime,
A.tStoreInTime,A.sMaterialNo,A.nStockQty,
CASE WHEN A.sLocation LIKE '%常运%' THEN '常运仓' ELSE '灵泰仓' END AS sLocation,
A.sCustomerName,A.sSalesGroupName,CASE WHEN ISNULL(A.sGrade,'A') ='' THEN 'A' ELSE ISNULL(A.sGrade,'A') END AS sGrade
INTO #TEMP
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].vwmmFPInStore A WITH(NOLOCK) 
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].vwsdOrder B with(nolock) ON B.usdOrderLotGUID = A.usdOrderLotGUID
LEFT JOIN [198.168.6.253].[HSFabricTrade_NJYY].[dbo].sdOrderHdr C with(nolock) ON B.sContractNo=C.sORDERNO
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].[mmFPInHdr] D WITH(NOLOCK) ON A.uGUID=D.uGUID
WHERE A.iStoreInStatus=1 AND A.nStockQty<>0 AND sStoreNo IN ('FP1103')

SELECT CONVERT(NVARCHAR(7),tStoreInTime,120) AS tStoreInTime
,SUM(nStockQty) AS nStockQty
,sGrade
,ISNULL(sSalesGroupName,'') AS sSalesGroupName
,ISNULL(sCustomerName,'') AS sCustomerName
,sLocation
INTO #TEMP2
FROM #TEMP
GROUP BY CONVERT(NVARCHAR(7),tStoreInTime,120)
,sGrade
,ISNULL(sSalesGroupName,'')
,ISNULL(sCustomerName,'')
,sLocation
ORDER BY tStoreInTime,sSalesGroupName

SELECT A.*,B.ID AS iD_B
INTO #TEMP3
FROM #TEMP2 A
LEFT JOIN [dbo].[pbCommonDataFPStore] B ON 
A.tStoreInTime  = B.tStoreInTime  AND A.nStockQty = B.nStockQty AND A.sGrade = B.sGrade 
AND A.sCustomerName = B.sCustomerName AND A.sLocation = B.sLocation AND A.sSalesGroupName = B.sSalesGroupName
WHERE B.ID IS NULL


SELECT *FROM [dbo].[pbCommonDataFPStore]

SELECT *FROM #TEMP3

SELECT *FROM [dbo].[pbCommonDataWorkingWIP]

--INSERT INTO [dbo].[pbCommonDataWorkingWIP](sWorkingProcedureName,sCeiling)
--SELECT '胚仓',12

--INSERT INTO [dbo].[pbCommonDataFPStore](
--tStoreInTime,nStockQty,sGrade,sSalesGroupName,sCustomerName,sLocation
--)
--SELECT tStoreInTime,nStockQty,sGrade,sSalesGroupName,sCustomerName,sLocation FROM #TEMP3


DROP TABLE #TEMP
DROP TABLE #TEMP2
DROP TABLE #TEMP3



