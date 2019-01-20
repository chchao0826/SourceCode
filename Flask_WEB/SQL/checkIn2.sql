DECLARE @sMonth DATETIME
SET @sMonth = GETDATE()

--加班单,去除调休部分
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
AND ISNULL(B.sremark,'') NOT LIKE '%调休%'

UPDATE #TEMPTABLE
SET sDeptName = '灵泰厂务室'
WHERE sEmployeeNameCN = '杜红光'

UPDATE #TEMPTABLE
SET sDeptName = '灵泰印花廠'
WHERE sDeptName LIKE '%印花%'

UPDATE #TEMPTABLE
SET sType = '白班'
WHERE sType IS NULL

CREATE TABLE #TEMPTABLE2(sDeptFullName NVARCHAR(30),sEmployeeName NVARCHAR(30),tCheckDay NVARCHAR(30),tCheckTime NVARCHAR(30),sType NVARCHAR(50))

INSERT INTO #TEMPTABLE2 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tStartTime,120), RIGHT(CONVERT(NVARCHAR(19),tStartTime,120),8),sType
FROM #TEMPTABLE

INSERT INTO #TEMPTABLE2 (sDeptFullName,sEmployeeName,tCheckDay,tCheckTime,sType)
SELECT sDeptName,sEmployeeNameCN,CONVERT(NVARCHAR(10),tEndTime,120), RIGHT(CONVERT(NVARCHAR(19),tEndTime,120),8),sType
FROM #TEMPTABLE

------打卡记录
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

------删除多余的打卡记录
DELETE #TEMP
WHERE nRowNumber > 1

--------每日考勤计数
SELECT id,sDeptName,sEmployeeName,tCheckTime
,ROW_NUMBER() OVER(PARTITION BY sDeptName, sEmployeeName ORDER BY tCheckTime) AS nRowNumber
INTO #TEMP2
FROM #TEMP

--------考勤总表
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

--------每日打卡不满2次的自动补齐
WHILE EXISTS(SELECT *FROM(SELECT COUNT(*) AS nCount FROM #TEMP3 GROUP BY sDeptName,sEmployeeName,tCheckDay) A WHERE nCount < 2)
BEGIN
INSERT INTO #TEMP3(uGUID,sDeptName,sEmployeeName,tCheckDay,sRemark)
SELECT NEWID(),A.sDeptName,sEmployeeName,tCheckDay,'未打卡'
FROM(
SELECT sDeptName,sEmployeeName,tCheckDay,COUNT(*) AS nCount
FROM #TEMP3
GROUP BY sDeptName,sEmployeeName,tCheckDay
) A
WHERE nCount < 2
END
------部门与ERP中对应
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

-- 加班单去除重复
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
SET sType = '白班'
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
WHERE A.sType = '白班' AND A.sWorkTime IS NULL AND D.bIsDayShift = 1

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
WHERE A.sType = '白班' AND A.sWorkTime IS NULL AND D.bIsDayShift = 1

UPDATE #TEMP3
SET sRemark =  ISNULL(sRemark,'')+CASE WHEN LEFT(tCheckTime ,2) <=13 AND tCheckTime > sWorkTime 
THEN '迟到' + CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + sWorkTime))+'分钟'
ELSE '' END
FROM #TEMP3 A
WHERE sType = '白班'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'')+CASE WHEN LEFT(tCheckTime ,2) >13 AND tCheckTime < sWorkTime 
THEN '打卡异常'
ELSE '' END
FROM #TEMP3 A
WHERE sType = '白班'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') +CASE WHEN DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) <= 0
AND DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) >= -60
THEN '迟到' + CONVERT(NVARCHAR(10),DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime))+'分钟'
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
WHERE A.sType <> '白班'

UPDATE #TEMP3
SET sRemark = ISNULL(sRemark,'') +CASE WHEN DATEDIFF(MINUTE,CONVERT(NVARCHAR(11),GETDATE(),120) + A.tCheckTime,CONVERT(NVARCHAR(11),GETDATE(),120) + A.sWorkTime) >= 0
THEN '打卡异常' ELSE '' END
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
WHERE A.sType <> '白班'




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
考勤表说明
取加班单去除调休部分
修改加班单中有问题的部门
加班单中未写班别的默认为白班
将加班单的考勤时间进行分离
上班时间(日期/时间)
下班时间(日期/时间)
查询考勤机打卡记录
删除同一个时段多余的打卡记录
进行每日考勤的计数
每日考勤不满两次的进行自动补齐
默认备注未打卡
考勤机中建立临时表#TEMP,UPDATE ERP中的部门
加班单中去除重复的内容
加班单加班信息导入考勤表
加班单中计数最小的放入考勤单中第一个位置
加班单中计数最大的放入考勤单中最后一个位置
将没有加班信息的人员默认增加白班类别
白班没有加班信息的增加默认的上班时间8:00下班时间17:00
白班使用13点之前的打卡对比上班时间 若打卡时间大于上班时间即为迟到
白班13之后的打卡对比上班时间 若小于即为打卡异常
不为白班的对打卡记录进行排序,计数最大的为上班时间 进行对比若打卡时间大于上班时间即返回迟到
不为白班的对打卡记录进行排序,计数最小的为下班时间 进行对比若打卡时间小于上班时间即返回打卡异常
*/