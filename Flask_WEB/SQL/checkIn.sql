--DROP TABLE [dbo].[pbCommonDataCheckIn]
--DROP TABLE [dbo].[pbCommonDataDepartment]
--DROP TABLE [dbo].[pbCommonDataEmployee]

--SELECT *FROM [dbo].[pbCommonDataCheckIn]
--SELECT *FROM [dbo].[pbCommonDataDepartment]
--SELECT *FROM [dbo].[pbCommonDataEmployee] A
--LEFT JOIN [dbo].[pbCommonDataDepartment] B ON A.ipbCommonDataDepartmentID = B.id

--UPDATE  [dbo].[pbCommonDataDepartment]
--SET bIsDayShift = 1
--WHERE sDeptName IN ('�з���','̨��','���ܿ�','���´�����','������չ','����������','�������'
--,'��Ѷ��','�عܲ�','�ֿ�','������','�ܾ�����','Ӫ����','����','�ɹ���','Ӫ����','�ִ��������','Ⱦ������')


--SELECT *FROM [dbo].[pbCommonDataDepartment]


DECLARE @sMonth DATETIME
SET @sMonth = GETDATE()


SELECT A.id,C.sDeptName,B.sEmployeeName AS sEmployeeName
,A.tCheckTime AS tCheckTime
,ROW_NUMBER() OVER(PARTITION BY C.sDeptName,B.sEmployeeName
,CONVERT(NVARCHAR(13),A.tCheckTime,120) ORDER BY C.sDeptName,B.sEmployeeName,A.tCheckTime) AS nRowNumber
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
,CONVERT(NVARCHAR(50),NULL) AS sRemark
,CONVERT(NVARCHAR(50),NULL) AS sDeptFullName
,CONVERT(NVARCHAR(50),NULL) AS sWorkTime
,CONVERT(NVARCHAR(50),NULL) AS sType
INTO #TEMP3
FROM (
SELECT A.sDeptName,A.sEmployeeName
,CONVERT(NVARCHAR(10),A.tCheckTime,120) AS tCheckDay
,RIGHT(CONVERT(NVARCHAR(19),A.tCheckTime,120),8) AS tCheckTime
FROM #TEMP2 A
) A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName
ORDER BY A.sDeptName,A.sEmployeeName,A.tCheckDay



WHILE EXISTS(SELECT *FROM(SELECT COUNT(*) AS nCount FROM #TEMP3 GROUP BY sDeptName,sEmployeeName,tCheckDay) A WHERE nCount < 2)
BEGIN
INSERT INTO #TEMP3(sDeptName,sEmployeeName,tCheckDay,sRemark)
SELECT A.sDeptName,sEmployeeName,tCheckDay,'δ��'
FROM(
SELECT sDeptName,sEmployeeName,tCheckDay,COUNT(*) AS nCount
FROM #TEMP3
GROUP BY sDeptName,sEmployeeName,tCheckDay
) A
WHERE nCount < 2
END

UPDATE #TEMP3 
SET sRemark = ISNULL(sRemark,'') + ISNULL(CASE WHEN tCheckTime >= '08:00:00' AND tCheckTime <= '09:00:00' 
THEN '�ٵ�-'+ CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,(CONVERT(NVARCHAR(11),GETDATE(),120)+'08:00:00' ),(CONVERT(NVARCHAR(11),GETDATE(),120)+ tCheckTime) )) +'����'
ELSE NULL END,'')
FROM #TEMP3 A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND B.bIsDayShift = 1

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + ISNULL(CASE WHEN tCheckTime >= '11:30:00' AND tCheckTime <= '13:00:00' THEN '�����' ELSE NULL END,'')
FROM #TEMP3 A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND B.bIsDayShift = 1

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + ISNULL(CASE WHEN tCheckTime >= '09:00:00' AND tCheckTime <= '11:30:00' THEN '���쳣' ELSE NULL END,'')
FROM #TEMP3 A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND B.bIsDayShift = 1

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + ISNULL(CASE WHEN tCheckTime >= '13:00:00' AND tCheckTime <= '16:00:00' THEN '���쳣' ELSE NULL END,'')
FROM #TEMP3 A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND B.bIsDayShift = 1

UPDATE #TEMP3
SET sDeptFullName = B.sDeptFullName
FROM #TEMP3 A
LEFT JOIN pbCommonDataDepartment B ON A.sDeptName = B.sDeptName


SELECT A.*
,CONVERT(NVARCHAR(50),NULL) AS sRemark
INTO #TEMP5
FROM (
SELECT A.sDeptName,A.sEmployeeName
,CONVERT(NVARCHAR(10),A.tCheckTime,120) AS tCheckDay
,RIGHT(CONVERT(NVARCHAR(19),A.tCheckTime,120),8) AS tCheckTime
FROM #TEMP2 A
) A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName AND ISNULL(B.bIsDayShift,0) = 0
ORDER BY A.sDeptName,A.sEmployeeName,A.tCheckDay



CREATE TABLE #TEMP6(sDeptFullName NVARCHAR(30),sEmployeeName NVARCHAR(30),tCheckDay NVARCHAR(30),tCheckTime NVARCHAR(30),sType NVARCHAR(50))

INSERT INTO #TEMP6 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tStartTime,120), RIGHT(CONVERT(NVARCHAR(19),tStartTime,120),8),sType
FROM #TEMP4

INSERT INTO #TEMP6 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tEndTime,120), RIGHT(CONVERT(NVARCHAR(19),tEndTime,120),8),sType
FROM #TEMP4

UPDATE #TEMP3
SET sWorkTime = B.tCheckTime ,sType = B.sType
FROM #TEMP3 A
JOIN #TEMP6 B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND B.tCheckDay = A.tCheckDay AND DATEDIFF(HOUR,B.tCheckTime,A.tCheckTime) <=1 AND DATEDIFF(HOUR,B.tCheckTime,A.tCheckTime) >= -1

UPDATE #TEMP3
SET sType = B.sType
FROM #TEMP3 A
JOIN #TEMP6 B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND B.tCheckDay = A.tCheckDay

--UPDATE #TEMP3
--SET sWorkTime = C.tCheckTime
--FROM #TEMP3 A
--JOIN #TEMP6 C ON A.sDeptFullName = C.sDeptFullName AND A.sEmployeeName = C.sEmployeeName AND C.tCheckDay = A.tCheckDay
--WHERE C.tCheckTime <> '08:00:00' AND A.tCheckTime > '09:00:00'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + CASE WHEN tCheckTime > sWorkTime AND sWorkTime = '08:00:00' THEN '�ٵ�' + CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,tCheckTime,sWorkTime))+'����' ELSE '' END
FROM #TEMP3 A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName 
WHERE ISNULL(sRemark,'') NOT LIKE '%�ٵ�%' AND ISNULL(sType,'') <>'ҹ��'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + CASE WHEN sWorkTime < tCheckTime THEN '�ٵ�' ELSE '' END
FROM #TEMP3 A
WHERE sType = 'ҹ��' AND sWorkTime >= '20:00:00'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + CASE WHEN sWorkTime > tCheckTime THEN '����' ELSE '' END
FROM #TEMP3 A
WHERE sType = 'ҹ��' AND sWorkTime <= '08:00:00'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') + CASE WHEN sWorkTime > tCheckTime THEN '����' ELSE '' END
FROM #TEMP3 A
WHERE ISNULL(sType,'') <> 'ҹ��' AND sWorkTime > '16:00:00'

SELECT *FROM #TEMP3 WHERE  sRemark LIKE '%����%'


--SELECT sDeptFullName,A.sDeptName,sEmployeeName,tCheckDay,tCheckTime
--FROM #TEMP5 A
--LEFT JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName


--UPDATE [dbo].[pbCommonDataDepartment]
--SET sDeptFullName = '��������'
--WHERE id = 30 


--SELECT *FROM [dbo].[pbCommonDataDepartment] A
--LEFT JOIN pbCommonDataEmployee B ON A.id = B.ipbCommonDataDepartmentID
--WHERE A.sDeptName = '̨��'


----���ڱ����
--SELECT *FROM #TEMP3
--WHERE sRemark LIKE '%�ٵ�%'

DROP TABLE #TEMP
DROP TABLE #TEMP2
DROP TABLE #TEMP3
DROP TABLE #TEMP4
DROP TABLE #TEMP5
DROP TABLE #TEMP6
