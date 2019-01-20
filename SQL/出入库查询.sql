--DECLARE @sFlag NVARCHAR(20), @sYear NVARCHAR(4)
--SET @sFlag = '成品入库'
--SET @sYear = CONVERT(NVARCHAR(4),'2018-01-10',120)

DECLARE @sFlag NVARCHAR(20), @sYear DATETIME
SET @sFlag = :[sFlag]
SET @sYear = CONVERT(NVARCHAR(4),:[sYear],120)

--成品入库
IF @sFlag = '成品入库'
BEGIN

SELECT CONVERT(NVARCHAR(7), A.tStoreInTime,120) AS sMonth ,'成品入库' AS sType,SUM(A.nInQty) AS nQty,SUM(A.nInNetQty) AS nNetQty ,SUM(A.nInGrossQty) AS nGrossQty, A.sSalesGroupName
INTO #TEMP1
FROM dbo.vwmmSTInStore A WITH(NOLOCK)
left join dbo.sdOrderLot B WITH(NOLOCK) on A.usdOrderLotGUID=B.uGUID
left join dbo.tmColor C WITH(NOLOCK) ON C.uGUID=B.utmColorGUID
WHERE A.iStoreInStatus=1 AND A.sStoreNo IN ( 'ST21' ) AND CONVERT(NVARCHAR(4),A.tStoreInTime,120) = @sYear
GROUP BY CONVERT(NVARCHAR(7), A.tStoreInTime,120),A.sSalesGroupName

CREATE TABLE #TEMPTABLE(
sSalesGroupName NVARCHAR(50),
Qty_01 DECIMAL(18,2), Gross_01 DECIMAL(18,2), Net_01 DECIMAL(18,2),
Qty_02 DECIMAL(18,2), Gross_02 DECIMAL(18,2), Net_02 DECIMAL(18,2),
Qty_03 DECIMAL(18,2), Gross_03 DECIMAL(18,2), Net_03 DECIMAL(18,2),
Qty_04 DECIMAL(18,2), Gross_04 DECIMAL(18,2), Net_04 DECIMAL(18,2),
Qty_05 DECIMAL(18,2), Gross_05 DECIMAL(18,2), Net_05 DECIMAL(18,2),
Qty_06 DECIMAL(18,2), Gross_06 DECIMAL(18,2), Net_06 DECIMAL(18,2),
Qty_07 DECIMAL(18,2), Gross_07 DECIMAL(18,2), Net_07 DECIMAL(18,2),
Qty_08 DECIMAL(18,2), Gross_08 DECIMAL(18,2), Net_08 DECIMAL(18,2),
Qty_09 DECIMAL(18,2), Gross_09 DECIMAL(18,2), Net_09 DECIMAL(18,2),
Qty_10 DECIMAL(18,2), Gross_10 DECIMAL(18,2), Net_10 DECIMAL(18,2),
Qty_11 DECIMAL(18,2), Gross_11 DECIMAL(18,2), Net_11 DECIMAL(18,2),
Qty_12 DECIMAL(18,2), Gross_12 DECIMAL(18,2), Net_12 DECIMAL(18,2),
)

INSERT INTO  #TEMPTABLE(sSalesGroupName)
SELECT sSalesGroupName FROM #TEMP1 GROUP BY sSalesGroupName ORDER BY sSalesGroupName

DECLARE @sSalesGroupName varchar(50), @nVar INT, @Qty NVARCHAR(10), @Gross NVARCHAR(10), @Net NVARCHAR(10)
DECLARE My_Cursor CURSOR 
FOR (SELECT sSalesGroupName FROM #TEMP1 GROUP BY sSalesGroupName)
OPEN My_Cursor;
FETCH NEXT FROM My_Cursor INTO @sSalesGroupName;
WHILE @@FETCH_STATUS = 0
    BEGIN
	   SET @nVar = 1
	   WHILE @nVar <= 12
	   BEGIN
	   SET @Qty = 'Qty_' + CASE WHEN LEN(@nVar) = 1 THEN '0'+CONVERT(NVARCHAR(1),@nVar) ELSE CONVERT(NVARCHAR(2),@nVar) END
	   SET @Gross = 'Gross_' + CASE WHEN LEN(@nVar) = 1 THEN '0'+CONVERT(NVARCHAR(1),@nVar) ELSE CONVERT(NVARCHAR(2),@nVar) END
	   SET @Net = 'Net_' + CASE WHEN LEN(@nVar) = 1 THEN '0'+CONVERT(NVARCHAR(1),@nVar) ELSE CONVERT(NVARCHAR(2),@nVar) END
	   EXEC(
	   'UPDATE #TEMPTABLE
	   SET '+@Qty+'= nQty,'+@Gross+' = nGrossQty,'+@Net+' = nNetQty
	   FROM #TEMPTABLE A
	   JOIN #TEMP1 B ON A.sSalesGroupName = B.sSalesGroupName
	   WHERE A.sSalesGroupName = '''+@sSalesGroupName+''' 
	   AND RIGHT(sMonth,2) = CASE WHEN LEN('''+@nVar+''') = 1 THEN ''0''+CONVERT(NVARCHAR(1),'''+@nVar+''') ELSE CONVERT(NVARCHAR(2),'''+@nVar+''') END
	   ')
	   SET @nVar = @nVar + 1
	   END
       FETCH NEXT FROM My_Cursor INTO @sSalesGroupName;
    END
CLOSE My_Cursor;
DEALLOCATE My_Cursor;

SELECT *FROM #TEMPTABLE

DROP TABLE #TEMP1
DROP TABLE #TEMPTABLE
END

--成品出库
IF @sFlag = '成品出库'
BEGIN

SELECT
CONVERT(NVARCHAR(4), A.tStoreOutTime,120) AS sYear
,'成品出库' AS sType
,SUM(A.nStoreOutQty) AS nQty
,SUM(A.nStoreOutNetQty) AS nNetQty
,SUM(A.nStoreOutGrossQty) AS nGrossQty
, A.sSalesGroupName
FROM dbo.vwmmSTOutStore A WITH(NOLOCK)
left join dbo.sdOrderLot B WITH(NOLOCK) on A.usdOrderLotGUID=B.uGUID
left join dbo.tmColor C WITH(NOLOCK) ON C.uGUID=B.utmColorGUID
WHERE A.iStoreInStatus=1 AND A.sStoreNo IN ( 'ST21' ) AND CONVERT(NVARCHAR(4),A.tStoreOutTime,120) = @sYear
GROUP BY CONVERT(NVARCHAR(4), A.tStoreOutTime,120),A.sSalesGroupName
ORDER BY sSalesGroupName
END

 --胚布入库
 IF @sFlag = '胚布入库'
BEGIN

SELECT 
CONVERT(NVARCHAR(4), A.tStoreInTime,120) AS sYear
,'胚布入库' AS sType
,sSalesGroupName
,SUM(nInQty) AS nQty
FROM dbo.vwmmFPInStore A WITH(NOLOCK)
WHERE A.sStoreNo IN ('FP1103') AND CONVERT(NVARCHAR(4),tStoreInTime,120) = @sYear
GROUP BY CONVERT(NVARCHAR(4), A.tStoreInTime,120),sSalesGroupName
ORDER BY sSalesGroupName
END


 --胚布出库
 IF @sFlag = '胚布出库'
BEGIN

SELECT 
CONVERT(NVARCHAR(4), A.tStoreOutTime,120) AS sYear
,'胚布出库' AS sType
,sSalesGroupName
,SUM(A.nStoreOutQty) AS nQty

FROM dbo.vwmmFPOutStore A WITH(NOLOCK)
WHERE A.sStoreNo IN ('FP1103') AND CONVERT(NVARCHAR(4),tStoreOutTime,120) = @sYear
GROUP BY CONVERT(NVARCHAR(4), A.tStoreOutTime,120),sSalesGroupName
ORDER BY sSalesGroupName
END


--幅宽*克重*0.9144/100=码重
--100kg=100000g/码重g/y=码数y
 --订单数量
 IF @sFlag = '订单数量'
BEGIN 
SELECT @sYear AS sYear,'订单数量' AS sType,sSalesGroupName,SUM(nNetQty) AS nNetQty,SUM(nQty) AS nQty
FROM(
SELECT 
sSalesGroupName,CONVERT(numeric(18,2),(nQty * 1000)/CASE WHEN (CONVERT(numeric(18,2),nProductWidth*nProductGMWT*0.9144/100)) = 0 THEN NULL ELSE CONVERT(numeric(18,2),(nProductWidth*nProductGMWT*0.9144/100)) END) AS nNetQty,nQty
FROM(
SELECT nQty
,CONVERT(numeric(18,2),CASE WHEN ISNUMERIC(LEFT(sProductGMWT,3)) = 1 THEN LEFT(sProductGMWT,3) 
WHEN ISNUMERIC(LEFT(sProductGMWT,2)) = 1 THEN LEFT(sProductGMWT,2) 
WHEN ISNUMERIC(LEFT(sProductGMWT,1)) = 1 THEN LEFT(sProductGMWT,1)  ELSE NULL END) AS nProductGMWT
,CONVERT(numeric(18,2),CASE WHEN ISNUMERIC(LEFT(sProductWidth,3)) = 1 THEN LEFT(sProductWidth,3) 
WHEN ISNUMERIC(LEFT(sProductWidth,2)) = 1 THEN LEFT(sProductWidth,2) 
WHEN ISNUMERIC(LEFT(sProductWidth,1)) = 1 THEN LEFT(sProductWidth,1)  ELSE NULL END) AS nProductWidth
,sSalesGroupName
FROM vwsdOrder  A
WHERE CONVERT(NVARCHAR(4),tAuditTime,120) = @sYear AND A.bUsable = 1 AND iBillStatus = 2
) A
) A
GROUP BY sSalesGroupName
ORDER BY sSalesGroupName
END