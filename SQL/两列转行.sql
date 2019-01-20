SELECT sWorkingProcedureGenre,sType,sMaterialNo,sMaterialName_PY AS sMaterialName,SUM(nQty) AS nQty,sSourceName,CONVERT(CHAR(4),tCreateTime,120) AS sYear
INTO #TEMP4
FROM #TEMP
GROUP BY sWorkingProcedureGenre,sType,sMaterialNo,sMaterialName_PY,sSourceName,CONVERT(CHAR(4),tCreateTime,120)
ORDER BY sSourceName,CONVERT(CHAR(4),tCreateTime,120)

DECLARE @strCN2 NVARCHAR(MAX)
SELECT @strCN2=ISNULL(@strCN2+',','')+ QUOTENAME(sYear) FROM  #TEMP4 GROUP BY sYear ORDER BY sYear
 --PRINT @DCN
 
 DECLARE @SqlStr2 NVARCHAR(1000)
SET @SqlStr2='
WITH ReportCard 
AS(
SELECT sWorkingProcedureGenre,sType,sMaterialNo,sMaterialName,sSourceName FROM #TEMP4
 )
SELECT * FROM #TEMP4 PIVOT(SUM(nQty) FOR sYear IN('+@strCN2+') ) AS T'
EXEC(@sqlstr2)