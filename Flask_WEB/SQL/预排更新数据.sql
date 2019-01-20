SELECT B.sWorkingProcedureName,B.iOrderNo,A.sCardNo,A.sEquipmentPrepareNo,C.sColorNo,D.sMaterialNo,A.tCardTime,A.sType
,P.tFactEndTime,A.nFactInputQty,A.sMaterialLot
,DATEDIFF(HOUR,P.tFactEndTime,GETDATE()) AS nTIME_Hour
,CONVERT(INT,NULL) AS bIsNeed
,CONVERT(NVARCHAR(50),NULL) AS sWorkingProcedureName_big
,CONVERT(NVARCHAR(50),NULL) AS sCustomerName
,CONVERT(nvarchar(50),NULL) AS sborder_Bottom_bgcolor
,C.sColorCatena + C.sColorLevel AS sColor
,A.uGUID AS upsWorkFlowCardGUID
,A.usdOrderLotGUID
INTO #TEMP
FROM dbo.psWorkFlowCard A 
JOIN dbo.pbWorkingProcedure B ON A.upbWorkingProcedureGUIDCurrent = B.uGUID
LEFT JOIN dbo.ppTrackJob I WITH(NOLOCK) ON A.uGUID=I.upsWorkFlowCardGUID AND I.upbWorkingProcedureGUID=B.uGUID and bIsCurrent=1
LEFT JOIN dbo.tmColor C ON A.utmColorGUID = C.uGUID
LEFT JOIN dbo.mmMaterial D ON A.ummMaterialGUID = D.uGUID
---------------
LEFT JOIN dbo.ppTrackJob P WITH(NOLOCK) ON A.uGUID=P.upsWorkFlowCardGUID AND P.iOrderProcedure=I.iOrderProcedure - 1
LEFT JOIN HSWarpERP_NJYY.dbo.pbWorkingProcedure Q WITH(NOLOCK) ON P.upbWorkingProcedureGUID = Q.uGUID
WHERE A.sStatus = '正常' AND A.tCardTime >= DATEADD(MONTH,-6,GETDATE()) AND A.bUsable =1 
--AND (sEquipmentPrepareNo LIKE '%C%')

UPDATE #TEMP
SET sCustomerName = B.sCustomerName
FROM  #TEMP A
LEFT JOIN vwsdOrder B ON A.usdOrderLotGUID = B.usdOrderLotGUID


UPDATE #TEMP
SET bIsNeed = 1
FROM #TEMP A
JOIN(
    SELECt *FROM (
            SELECT A.sCardNo,C.sWorkingProcedureName,B.tFactEndTime
            FROM #TEMP A
            LEFT JOIN　dbo.ppTrackJob B ON A.upsWorkFlowCardGUID = B.upsWorkFlowCardGUID
            LEFT JOIN dbo.pbWorkingProcedure C ON C.uGUID = B.upbWorkingProcedureGUID
    )A 
    WHERE A.tFactEndTime IS NULL AND A.sWorkingProcedureName IN ('染色','進缸还原洗','缸練','改染','试修','剥色','皂洗','進缸修')
)B On A.sCardNo = B.sCardNo

DELETE #TEMP
WHERE bIsNeed IS NULL OR ISNULL(sEquipmentPrepareNo,'') = ''


UPDATE #TEMP
SET sWorkingProcedureName_big = '染色'
WHERE sWorkingProcedureName IN ('染色','進缸还原洗','缸練','改染','试修','剥色','皂洗','進缸修','訂邊','脫水+展布')

UPDATE #TEMP
SET sWorkingProcedureName_big = '化验室'
WHERE sWorkingProcedureName IN ('打色','復色','半成品套色','成品套色')

UPDATE #TEMP
SET sWorkingProcedureName_big = '水洗预定'
WHERE sWorkingProcedureName IN ('水洗','精煉','预定','低溫預定','高溫預定','刷毛','磨毛','雙面磨毛','缸練','高溫預定','烘干')

UPDATE #TEMP
SET sWorkingProcedureName_big = '退卷'
WHERE sWorkingProcedureName IN ('配檢+退卷','退卷','配檢布')

UPDATE #TEMP
SET sWorkingProcedureName_big = '配检布'
WHERE sWorkingProcedureName IN ('配檢布')


UPDATE #TEMP
SET sWorkingProcedureName_big = sWorkingProcedureName
WHERE sWorkingProcedureName_big IS NULL


create table #TT (sEquipmentNo nvarchar(20)
,sCardNo nvarchar(20)
,startedtime DATETIME
,nRowNumber nvarchar(20)
,BatchRefNo INT
,next INT
)

INSERT INTO #TT(sEquipmentNo,sCardNo,startedtime,nRowNumber,BatchRefNo,next)
select A.Machine_No AS sEquipmentNo,CASE WHEN A.procedure_no IN ('999','998','99','9997','9998','9999') or A.batch_text_01  like '201%' then '洗缸' else  A.batch_text_01 end as sCardNo
,right(left(convert(nvarchar(16),A.started,120),120),120) as startedtime
,1 AS nRowNumber
,B.BatchRefNo
,B.next
from  [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] A WITH(NOLOCK) 
left join [198.168.6.197].[ORGATEX].[dbo].[BatchChain] B WITH(NOLOCK) ON B.MachineNo=A.Machine_No  AND B.PREV =''
WHERE CONVERT(NVARCHAR(10),A.started,120) = CONVERT(NVARCHAR(10),GETDATE(),120)

INSERT INTO #TT(sEquipmentNo,sCardNo,nRowNumber)
SELECT C.Machine_No,C.batch_text_01,2 FROM #TT A
join [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] C WITH(NOLOCK) on A.BatchRefNo=C.batch_ref_no  
							and C.queued >=  (CONVERT(NVARCHAR(10), DATEADD(DD, -5, GETDATE()), 120)+' 8:00' )

INSERT INTO #TT(sEquipmentNo,sCardNo,nRowNumber)
SELECT D.Machine_No,D.batch_text_01,3 FROM #TT A
join [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] D WITH(NOLOCK) on A.next=D.batch_ref_no 
							and D.queued >=  (CONVERT(NVARCHAR(10), DATEADD(DD, -5, GETDATE()), 120)+' 8:00' )

UPDATE #TEMP
SET sborder_Bottom_bgcolor = CASE WHEN B.nRowNumber = 1 THEN  '#1E90FF' WHEN B.nRowNumber = 2 THEN '#2E8B57' ELSE NULL END
FROM #TEMP A
LEFT JOIN #TT B ON A.sCardNo = B.sCardNo

UPDATE #TEMP
SET sborder_Bottom_bgcolor =  CASE WHEN nTIME_Hour >= 72 THEN '#FF0000' WHEN nTIME_Hour >= 48 THEN '#FFD700' ELSE NULL END
FROM #TEMP
where sborder_Bottom_bgcolor IS NULL


---------------更新卡号的工段
UPDATE [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr
SET sWorkingProcedureName = B.sWorkingProcedureName
,sborder_left_bgcolor = CASE WHEN B.sWorkingProcedureName_big = '染色' THEN '#4bcce2' 
WHEN B.sWorkingProcedureName_big = '化验室' THEN '#00FA9A' 
WHEN B.sWorkingProcedureName_big = '水洗预定' THEN '#FFA500' 
WHEN B.sWorkingProcedureName_big = '退卷' THEN '#FF6347'  
WHEN B.sWorkingProcedureName_big = '配检布' THEN '#008080'  
ELSE NULL END 
,nFactInputQty = B.nFactInputQty
,nTIME_Hour =B.nTIME_Hour
,sborder_Bottom_bgcolor = B.sborder_Bottom_bgcolor
FROM [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr A
JOIN #TEMP B ON A.sCardNo = B.sCardNo


DROP TABLE #TEMP
DROP TABLE #TT
