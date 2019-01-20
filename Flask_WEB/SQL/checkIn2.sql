DECLARE @sMonth DATETIME
SET @sMonth = GETDATE()

--�Ӱ൥,ȥ�����ݲ���
SELECT A.sDeptName AS sDeptName
,C.sEmployeeNameCN AS sEmployeeNameCN
,ISNULL(B.tStartTime,B.tstartworktime) AS tStartTime
,ISNULL(B.toverworktime,B.tEndTime) AS tEndTime
,B.sType AS sType
INTO #TEMPTABLE
FROM [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourHdr] A
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourDtl] B ON A.uGUID = B.upbCommonDataworkhourHdrGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].[pbCommonDataworkhourEmployee] C ON B.uGUID = C.upbCommonDataworkhourDtlGUID
WHERE CONVERT(NVARCHAR(7),ISNULL(B.tStartTime,B.tstartworktime),120) >= CONVERT(NVARCHAR(7),DATEADD(MONTH,-1,@sMonth),120)
AND ISNULL(B.sremark,'') NOT LIKE '%����%'

UPDATE #TEMPTABLE
SET sDeptName = '��̩������'
WHERE sEmployeeNameCN = '�ź��'

UPDATE #TEMPTABLE
SET sDeptName = '��̩ӡ���S'
WHERE sDeptName LIKE '%ӡ��%'

UPDATE #TEMPTABLE
SET sType = '�װ�'
WHERE sType IS NULL

CREATE TABLE #TEMPTABLE2(sDeptFullName NVARCHAR(30),sEmployeeName NVARCHAR(30),tCheckDay NVARCHAR(30),tCheckTime NVARCHAR(30),sType NVARCHAR(50))

INSERT INTO #TEMPTABLE2 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tStartTime,120), RIGHT(CONVERT(NVARCHAR(19),tStartTime,120),8),sType
FROM #TEMPTABLE

INSERT INTO #TEMPTABLE2 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tEndTime,120), RIGHT(CONVERT(NVARCHAR(19),tEndTime,120),8),sType
FROM #TEMPTABLE

------�򿨼�¼
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

------ɾ������Ĵ򿨼�¼
DELETE #TEMP
WHERE nRowNumber > 1

--------ÿ�տ��ڼ���
SELECT id,sDeptName,sEmployeeName,tCheckTime
,ROW_NUMBER() OVER(PARTITION BY sDeptName, sEmployeeName ORDER BY tCheckTime) AS nRowNumber
INTO #TEMP2
FROM #TEMP

--------�����ܱ�
SELECT A.*
,CONVERT(NVARCHAR(50),NULL) AS sRemark
,CONVERT(NVARCHAR(50),NULL) AS sDeptFullName
,CONVERT(NVARCHAR(50),NULL) AS sWorkTime
,CONVERT(NVARCHAR(50),NULL) AS sType
,NEWID() AS uGUID
INTO #TEMP3
FROM (
SELECT A.sDeptName,A.sEmployeeName
,CONVERT(NVARCHAR(10),A.tCheckTime,120) AS tCheckDay
,RIGHT(CONVERT(NVARCHAR(19),A.tCheckTime,120),8) AS tCheckTime
FROM #TEMP2 A
) A
JOIN [dbo].[pbCommonDataDepartment] B ON A.sDeptName = B.sDeptName
ORDER BY A.sDeptName,A.sEmployeeName,A.tCheckDay

--------ÿ�մ򿨲���2�ε��Զ�����
WHILE EXISTS(SELECT *FROM(SELECT COUNT(*) AS nCount FROM #TEMP3 GROUP BY sDeptName,sEmployeeName,tCheckDay) A WHERE nCount < 2)
BEGIN
INSERT INTO #TEMP3(uGUID,sDeptName,sEmployeeName,tCheckDay,sRemark)
SELECT NEWID(),A.sDeptName,sEmployeeName,tCheckDay,'δ��'
FROM(
SELECT sDeptName,sEmployeeName,tCheckDay,COUNT(*) AS nCount
FROM #TEMP3
GROUP BY sDeptName,sEmployeeName,tCheckDay
) A
WHERE nCount < 2
END
------������ERP�ж�Ӧ
UPDATE #TEMP3
SET sDeptFullName = B.sDeptFullName
FROM #TEMP3 A
LEFT JOIN pbCommonDataDepartment B ON A.sDeptName = B.sDeptName

SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
INTO #TEMP4
FROM #TEMP3

SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
INTO #TEMPTABLE3
FROM #TEMPTABLE2

-- �Ӱ൥ȥ���ظ�
SELECT A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.tCheckTime,A.sType
INTO #TEMPTABLE4
FROM #TEMPTABLE3 A
JOIN(
SELECT sDeptFullName,sEmployeeName,tCheckDay,MAX(nRowNumber) AS nRowNumber_MAX,MIN(nRowNumber) AS nRowNumber_MIN
FROM #TEMPTABLE3
GROUP BY sDeptFullName,sEmployeeName,tCheckDay
)B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber_MIN

INSERT INTO #TEMPTABLE4(sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.tCheckTime,A.sType
FROM #TEMPTABLE3 A
JOIN(
SELECT sDeptFullName,sEmployeeName,tCheckDay,MAX(nRowNumber) AS nRowNumber_MAX,MIN(nRowNumber) AS nRowNumber_MIN
FROM #TEMPTABLE3
GROUP BY sDeptFullName,sEmployeeName,tCheckDay
)B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber_MAX

UPDATE #TEMP3
SET sWorkTime = C.tCheckTime,sType = C.sType
FROM #TEMP3 A
JOIN(
SELECT A.uGUID,A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.tCheckTime FROM
(
SELECT uGUID,sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,nRowNumber
FROM #TEMP4
)A
JOIN (
SELECT sDeptFullName,sEmployeeName,tCheckDay,MIN(nRowNumber) AS nRowNumber
FROM #TEMP4
GROUP BY sDeptFullName,sEmployeeName,tCheckDay
) B ON A.sDeptFullName =B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
) B ON A.uGUID = B.uGUID
JOIN(
SELECT A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.sType,A.nRowNumber,A.tCheckTime FROM(
SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
FROM #TEMPTABLE4
) A
JOIN (
SELECT A.sDeptFullName,sEmployeeName,tCheckDay,sType,MIN(nRowNumber) AS nRowNumber FROM(
SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
FROM #TEMPTABLE4
) A
GROUP BY A.sDeptFullName,sEmployeeName,tCheckDay,sType
)B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
) C ON B.sDeptFullName = C.sDeptFullName AND C.sEmployeeName = B.sEmployeeName AND C.tCheckDay = B.tCheckDay



UPDATE #TEMP3
SET sWorkTime = C.tCheckTime,sType = C.sType
FROM #TEMP3 A
JOIN(
SELECT A.uGUID,A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.tCheckTime FROM
(
SELECT uGUID,sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,nRowNumber
FROM #TEMP4
)A
JOIN (
SELECT sDeptFullName,sEmployeeName,tCheckDay,MAX(nRowNumber) AS nRowNumber
FROM #TEMP4
GROUP BY sDeptFullName,sEmployeeName,tCheckDay
) B ON A.sDeptFullName =B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
) B ON A.uGUID = B.uGUID
JOIN(
SELECT A.sDeptFullName,A.sEmployeeName,A.tCheckDay,A.sType,A.nRowNumber,A.tCheckTime FROM(
SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
FROM #TEMPTABLE4
) A
JOIN (
SELECT A.sDeptFullName,sEmployeeName,tCheckDay,sType,MAX(nRowNumber) AS nRowNumber FROM(
SELECT *
,ROW_NUMBER() OVER(PARTITION BY sDeptFullName,sEmployeeName,tCheckDay ORDER BY sDeptFullName,sEmployeeName,tCheckDay,tCheckTime) AS nRowNumber
FROM #TEMPTABLE4
) A
GROUP BY A.sDeptFullName,sEmployeeName,tCheckDay,sType
)B ON A.sDeptFullName = B.sDeptFullName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
) C ON B.sDeptFullName = C.sDeptFullName AND C.sEmployeeName = B.sEmployeeName AND C.tCheckDay = B.tCheckDay




UPDATE #TEMP3
SET sType = '�װ�'
WHERE sType IS NULL

UPDATE #TEMP3
SET sWorkTime = '08:00:00'
FROM #TEMP3 A
JOIN #TEMP4 B ON A.uGUID = B.uGUID
JOIN(
SELECT sDeptName,sEmployeeName,tCheckDay,MIN(nRowNumber) AS nRowNumber
FROM #TEMP4
GROUP BY sDeptName,sEmployeeName,tCheckDay
)C ON C.sDeptName = B.sDeptName AND C.tCheckDay = B.tCheckDay AND B.nRowNumber = C.nRowNumber
JOIN pbCommonDataDepartment D ON A.sDeptName = D.sDeptName
WHERE A.sType = '�װ�' AND A.sWorkTime IS NULL AND D.bIsDayShift = 1

UPDATE #TEMP3
SET sWorkTime = '17:00:00'
FROM #TEMP3 A
JOIN #TEMP4 B ON A.uGUID = B.uGUID
JOIN(
SELECT sDeptName,sEmployeeName,tCheckDay,MAX(nRowNumber) AS nRowNumber
FROM #TEMP4
GROUP BY sDeptName,sEmployeeName,tCheckDay
)C ON C.sDeptName = B.sDeptName AND C.tCheckDay = B.tCheckDay AND B.nRowNumber = C.nRowNumber
JOIN pbCommonDataDepartment D ON A.sDeptName = D.sDeptName
WHERE A.sType = '�װ�' AND A.sWorkTime IS NULL AND D.bIsDayShift = 1

UPDATE #TEMP3
SET sRemark =  ISNULL(sRemark,'')+CASE WHEN LEFT(tCheckTime ,2) <=13 AND tCheckTime > sWorkTime 
THEN '�ٵ�' + CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + sWorkTime))+'����'
ELSE '' END
FROM #TEMP3 A
WHERE sType = '�װ�'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'')+CASE WHEN LEFT(tCheckTime ,2) >13 AND tCheckTime < sWorkTime 
THEN '���쳣'
ELSE '' END
FROM #TEMP3 A
WHERE sType = '�װ�'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') +CASE WHEN DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) <= 0
AND DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) >= -60
THEN '�ٵ�' + CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime))+'����'
ELSE '' END
FROM #TEMP3 A
JOIN(
SELECT A.sDeptName,A.sEmployeeName,A.tCheckDay,A.tCheckTime FROM(
SELECT *,ROW_NUMBER() OVER(PARTITION BY sDeptName,sEmployeeName,tCheckDay ORDER BY sDeptName,sEmployeeName,tCheckDay,sWorkTime) AS nRowNumber FROM #TEMP3
)  A
JOIN(
SELECT A.sDeptName,A.sEmployeeName,A.tCheckDay,MAX(nRowNumber) AS nRowNumber FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY sDeptName,sEmployeeName,tCheckDay ORDER BY sDeptName,sEmployeeName,tCheckDay,sWorkTime) AS nRowNumber FROM #TEMP3
)A
GROUP BY A.sDeptName,A.sEmployeeName,A.tCheckDay
)B ON A.sDeptName = B.sDeptName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
)B ON A.sDeptName = B.sDeptName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.tCheckTime = B.tCheckTime
WHERE A.sType <> '�װ�'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') +CASE WHEN DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) >= 0
THEN '���쳣' ELSE '' END
FROM #TEMP3 A
JOIN(
SELECT A.sDeptName,A.sEmployeeName,A.tCheckDay,A.tCheckTime FROM(
SELECT *,ROW_NUMBER() OVER(PARTITION BY sDeptName,sEmployeeName,tCheckDay ORDER BY sDeptName,sEmployeeName,tCheckDay,sWorkTime) AS nRowNumber FROM #TEMP3
)  A
JOIN(
SELECT A.sDeptName,A.sEmployeeName,A.tCheckDay,MIN(nRowNumber) AS nRowNumber FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY sDeptName,sEmployeeName,tCheckDay ORDER BY sDeptName,sEmployeeName,tCheckDay,sWorkTime) AS nRowNumber FROM #TEMP3
)A
GROUP BY A.sDeptName,A.sEmployeeName,A.tCheckDay
)B ON A.sDeptName = B.sDeptName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.nRowNumber = B.nRowNumber
)B ON A.sDeptName = B.sDeptName AND A.sEmployeeName = B.sEmployeeName AND A.tCheckDay = B.tCheckDay AND A.tCheckTime = B.tCheckTime
WHERE A.sType <> '�װ�'




SELECT *
FROM #TEMP3
ORDER BY sDeptName,sEmployeeName,tCheckDay,sWorkTime


DROP TABLE #TEMPTABLE
DROP TABLE #TEMPTABLE2
DROP TABLE #TEMPTABLE3
DROP TABLE #TEMPTABLE4
DROP TABLE #TEMP
DROP TABLE #TEMP2
DROP TABLE #TEMP3
DROP TABLE #TEMP4

/*
���ڱ�˵��
ȡ�Ӱ൥ȥ�����ݲ���
�޸ļӰ൥��������Ĳ���
�Ӱ൥��δд����Ĭ��Ϊ�װ�
���Ӱ൥�Ŀ���ʱ����з���
�ϰ�ʱ��(����/ʱ��)
�°�ʱ��(����/ʱ��)
��ѯ���ڻ��򿨼�¼
ɾ��ͬһ��ʱ�ζ���Ĵ򿨼�¼
����ÿ�տ��ڵļ���
ÿ�տ��ڲ������εĽ����Զ�����
Ĭ�ϱ�עδ��
���ڻ��н�����ʱ��#TEMP,UPDATE ERP�еĲ���
�Ӱ൥��ȥ���ظ�������
�Ӱ൥�Ӱ���Ϣ���뿼�ڱ�
�Ӱ൥�м�����С�ķ��뿼�ڵ��е�һ��λ��
�Ӱ൥�м������ķ��뿼�ڵ������һ��λ��
��û�мӰ���Ϣ����ԱĬ�����Ӱװ����
�װ�û�мӰ���Ϣ������Ĭ�ϵ��ϰ�ʱ��8:00�°�ʱ��17:00
�װ�ʹ��13��֮ǰ�Ĵ򿨶Ա��ϰ�ʱ�� ����ʱ������ϰ�ʱ�伴Ϊ�ٵ�
�װ�13֮��Ĵ򿨶Ա��ϰ�ʱ�� ��С�ڼ�Ϊ���쳣
��Ϊ�װ�ĶԴ򿨼�¼��������,��������Ϊ�ϰ�ʱ�� ���жԱ�����ʱ������ϰ�ʱ�伴���سٵ�
��Ϊ�װ�ĶԴ򿨼�¼��������,������С��Ϊ�°�ʱ�� ���жԱ�����ʱ��С���ϰ�ʱ�伴���ش��쳣
*/