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
LEFT JOIN #TEMP B ON A.sCardNo = B.sCardNo


---删除预排表中有的数据
DELETE #TEMP
WHERE sCardNo IN (SELECT sCardNo FROM [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr)

--SELECT A.*,B.nRowNumber + 1 AS nRowNumber FROM #TEMP A
--LEFT JOIN (
--SELECT sEquipmentPrepareNo,MAX(nRowNumber) AS nRowNumber 
--FROM [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr
--GROUP BY sEquipmentPrepareNo
--)B ON A.sEquipmentPrepareNo = B.sEquipmentPrepareNo

--------插入
--INSERT INTO [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr(sCardNo,sEquipmentPrepareNo,nRowNumber,sWorkingProcedureName,sCustomerName
--,nFactInputQty,sColorNo,sMaterialNo,sMaterialLot,nTIME_Hour,sType,sborder_left_bgcolor,sli_bgcolor,sborder_Bottom_bgcolor
--)
SELECT A.sCardNo,A.sEquipmentPrepareNo
,ROW_NUMBER() OVER(PARTITION BY A.sEquipmentPrepareNo ORDER BY A.iOrderNo DESC,A.sType DESC,A.tFactEndTime)+ B.nRowNumber AS nRowNumber
,A.sWorkingProcedureName,A.sCustomerName,A.nFactInputQty,A.sColorNo,A.sMaterialNo,A.sMaterialLot,A.nTIME_Hour,A.sType
,CASE WHEN A.sWorkingProcedureName_big = '染色' THEN '#4bcce2' 
WHEN A.sWorkingProcedureName_big = '化验室' THEN '#00FA9A' 
WHEN A.sWorkingProcedureName_big = '水洗预定' THEN '#FFA500' 
WHEN A.sWorkingProcedureName_big = '退卷' THEN '#FF6347'  
WHEN A.sWorkingProcedureName_big = '配检布' THEN '#008080'  
ELSE NULL END AS sborder_left_bgcolor

,CASE WHEN sColor = 'B1' THEN '#ADD8E6' 
WHEN sColor = 'B2' THEN '#00BFFF' 
WHEN sColor = 'B3' THEN '#1E90FF' 
WHEN sColor = 'B4' THEN '#0000FF'
WHEN sColor = 'B5' THEN '#00008B'  

WHEN sColor = 'C1' THEN '#FFFFCC' 
WHEN sColor = 'C2' THEN '#FFCC66' 
WHEN sColor = 'C3' THEN '#FFCC00' 
WHEN sColor = 'C4' THEN '#CC99090'
WHEN sColor = 'C5' THEN '#993300'  

WHEN sColor = 'G1' THEN '#99FF99' 
WHEN sColor = 'G2' THEN '#66FF66' 
WHEN sColor = 'G3' THEN '#33FF33' 
WHEN sColor = 'G4' THEN '#00FF00'
WHEN sColor = 'G5' THEN '#00CC00'  

WHEN sColor IN ('K3','K4','K5') THEN '#000000' 
WHEN sColor = 'O1' THEN '#FFFFCC' 
WHEN sColor = 'O2' THEN '#FFCC66' 
WHEN sColor = 'O3' THEN '#FF9900' 
WHEN sColor = 'O4' THEN '#FF6600'
WHEN sColor = 'O5' THEN '#CC3300'  

WHEN sColor = 'P1' THEN '#DCDCDC' 
WHEN sColor = 'P2' THEN '#D3D3D3' 
WHEN sColor = 'P3' THEN '#A9A9A9' 
WHEN sColor = 'P4' THEN '#808080'
WHEN sColor = 'P5' THEN '#696969'  

WHEN sColor = 'R1' THEN '#FFE4E1' 
WHEN sColor = 'R2' THEN '#F08080' 
WHEN sColor = 'R3' THEN '#CD5C5C' 
WHEN sColor = 'R4' THEN '#FF0000'
WHEN sColor = 'R5' THEN '#8B0000'  

WHEN sColor = 'V1' THEN '#E6E6FA' 
WHEN sColor = 'V2' THEN '#EE82EE' 
WHEN sColor = 'V3' THEN '#FF00FF' 
WHEN sColor = 'V4' THEN '#9400D3'
WHEN sColor = 'V5' THEN '#800080'  

WHEN sColor = 'W1' THEN '#FFFFF0' 
WHEN sColor = 'W2' THEN '#fcefe8' 
WHEN sColor = 'W3' THEN '#e3f9fd' 
WHEN sColor = 'W4' THEN '#f0fcff'
WHEN sColor = 'W5' THEN '#ffffff'  

WHEN sColor = 'Y1' THEN '#FAFAD2' 
WHEN sColor = 'Y2' THEN '#F0E68C' 
WHEN sColor = 'Y3' THEN '#FFFF00' 
WHEN sColor = 'Y4' THEN '#FFD700'
WHEN sColor = 'Y5' THEN '#DAA520'  
ELSE NULL END AS sli_bgcolor
,sborder_Bottom_bgcolor
FROM #TEMP A
LEFT JOIN (
SELECT sEquipmentPrepareNo,MAX(nRowNumber) AS nRowNumber 
FROM [198.168.6.236].[YYLT].dbo.pbCommonDataExpectProduceHdr
GROUP BY sEquipmentPrepareNo
)B ON A.sEquipmentPrepareNo = B.sEquipmentPrepareNo






DROP TABLE #TEMP
DROP TABLE #TT
