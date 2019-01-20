execSql = "DECLARE @tStartTime DATETIME,@tEndTime DATETIME \
SET @tStartTime = CONVERT(NVARCHAR(10),GETDATE()-1,120) \
SET @tEndTime = CONVERT(NVARCHAR(10),GETDATE(),120) \
SELECT A.uGUID,E.sCardNo,F.sMaterialNo,G.sColorNo AS sLotColorNo,G.sColorName AS sLotColorName \
,F.sProductGMWT,E.nFactInputQty,A.tFactStartTime \
,CASE WHEN A.tFactEndTime>@tEndTime THEN NULL ELSE A.tFactEndTime END AS tFactEndTime \
,CASE WHEN F.sCustomerName IS NULL THEN NULL ELSE left(F.sCustomerName,6) END AS sCustomerName \
,CASE WHEN F.sProductWidth IS NULL THEN NULL ELSE left(F.sProductWidth,3) END AS sProductWidth \
,DATEDIFF(ss,A.tFactStartTime,A.tFactEndTime)/60.0 AS nMinSS \
,CASE WHEN B.sWorkingProcedureName='進缸还原洗' then '还原洗' else sWorkingProcedureName end as sWorkingProcedureName \
,CONVERT(NVARCHAR(100),NULL) AS sEquipmentNo \
,CONVERT(NVARCHAR(100),NULL) AS sWorkerNameList, CONVERT(NVARCHAR(50),NULL) AS sWorkerGroupName,CONVERT(NVARCHAR(50), NULL) AS sEquipmentgroupNo \
,A.upsWorkFlowCardGUID,CONVERT(NVARCHAR(100), NULL) AS sPrescriptionCardNoList,A.uemEquipmentGUID \
,case when G.scolorlevel is null then '' else scolorlevel end as scolorlevel \
,case when sColorCatena='k' then '黑'  when sColorCatena='G' then '綠' \
when sColorCatena='R' then '紅' when sColorCatena='B' then '藍' \
when sColorCatena='P' then '灰' when sColorCatena='C' then '膚' \
when sColorCatena='V' then '紫' when sColorCatena='O' then '橘' \
when sColorCatena='Y' then '黃' when sColorCatena='W' then '白' else sColorCatena end as sColorCatena \
INTO #TEMPTrackJob \
FROM dbo.ppTrackJob A WITH(NOLOCK) \
JOIN dbo.pbWorkingProcedure B WITH(NOLOCK) ON B.uGUID= A.upbWorkingProcedureGUID \
LEFT JOIN dbo.smUser D WITH(NOLOCK) ON A.sFactEndMan=D.sUserID \
JOIN dbo.psWorkFlowCard E WITH(NOLOCK) ON A.upsWorkFlowCardGUID=E.uGUID \
JOIN dbo.pbWorkCentre W WITH(NOLOCK) ON E.upbWorkCentreGUID = W.uGUID  \
JOIN dbo.vwsdOrder F WITH(NOLOCK) ON E.usdOrderLotGUID = F.usdOrderLotGUID \
LEFT JOIN [HSWarpERP_NJYY].dbo.tmColor G WITH(NOLOCK) ON E.utmColorGUID = G.uGUID \
WHERE  W.sWorkCentreNo IN ('L32300','L32400','L35500','L32200' ) AND A.bUsable=1 \
AND F.sOrderType IN ( SELECT Item FROM [dbo].[fnpbConvertStringToTable]('D,K,G,LTKJ,L,I,IL,S,J',',') ) \
AND ((A.tFactEndTime BETWEEN @tStartTime AND @tEndTime)  OR ( A.tFactStartTime  BETWEEN @tStartTime AND @tEndTime )) \
AND  B.sWorkingProcedureName IN ('染色','進缸还原洗','缸練','改染','剥色','皂洗','進缸修','洗缸') \
UPDATE #TEMPTrackJob \
SET sPrescriptionCardNoList=dbo.fntmPrescriptionUsageCardNoListGet(C.uGUID) \
FROM #TEMPTrackJob A \
JOIN dbo.tmPrescriptionUsage B WITH (NOLOCK) ON B.sCardNo=A.sCardNo \
JOIN dbo.tmPrescriptionHdr C WITH (NOLOCK) ON C.uGUID = B.utmPrescriptionHdrGUID AND C.sPrescriptionType IN (N'正常',N'加料') \
LEFT JOIN tmDyeingCurveHdr D WITH (NOLOCK) ON D.uGUID = C.utmDyeingCurveHdrGUID \
UPDATE #TEMPTrackJob \
SET sEquipmentNo = case when C.sEquipmentNo is null then convert(nvarchar(20),D.sEquipmentNo)+ CHAR(10)+ convert(nvarchar(20),d.ncapacity)  + CHAR(10)+  convert(nvarchar(20),d.sbrand) \
else convert(nvarchar(20),C.sEquipmentNo) +CHAR(10)+ convert(nvarchar(20),C.ncapacity) +CHAR(10)+ convert(nvarchar(20),C.sbrand) end \
,sWorkerNameList=B.sWorkerNameList,sWorkerGroupName=B.sWorkerGroupName \
,sEquipmentgroupNo= case when  C.sEquipmentLocation is null then D.sEquipmentLocation else C.sEquipmentLocation end \
FROM #TEMPTrackJob A \
LEFT JOIN ppTrackOutput B WITH(NOLOCK) ON B.uppTrackJobGUID = A.uGUID \
LEFT JOIN emEquipment C WITH(NOLOCK) ON C.uGUID = B.uemEquipmentGUID \
LEFT JOIN emEquipment D WITH(NOLOCK) ON D.uGUID = A.uemEquipmentGUID \
SELECT uGUID,sEquipmentgroupNo,sEquipmentNo,sCardNo,nFactInputQty,sCustomerName,sProductGMWT,sMaterialNo,sLotColorNo,sLotColorName,tFactStartTime,tFactEndTime,nMinSS \
,sWorkingProcedureName,convert(nvarchar(10),sColorCatena) +convert(nvarchar(10),scolorlevel) as sColorCatena \
,CASE WHEN sPrescriptionCardNoList IS NULL THEN sCardNo ELSE sPrescriptionCardNoList END AS sPrescriptionCardNoList \
,CONVERT(NVARCHAR(50), NULL) AS sType \
,CONVERT(NVARCHAR(100), NULL) AS sRepairReason \
INTO #TEMP \
FROM #TEMPTrackJob \
ORDER BY sEquipmentNo \
UPDATE #TEMP \
SET sType=B.sType \
,sRepairReason=B.sRepairReason \
FROM #TEMP A \
JOIN pbCommonDataDyeAbnormal B ON B.sCardNo = A.sCardNo \
WHERE B.iCommonType=304 \
select scardno1,MAX(tcreatetime) as tcreatetime \
INTO #TEMP4 \
from HSWarpERP_NJYY.dbo.tmprescriptionHdr \
where tcreatetime>getdate()-30  group by scardno1 \
select sPrescriptionno,D.scardno1,case when left(sTempProcName,3) like '%C%' then left(sTempProcName,2) else left(sTempProcName,3) end as sTempProcName \
INTO #TEMP6 \
from #TEMP4 D \
join HSWarpERP_NJYY.dbo.tmprescriptionHdr  E ON E.scardno1=D.scardno1 and E.tcreatetime=D.tcreatetime \
join  tmprescriptiondtl  F WITH(NOLOCK) on E.uGUID=F.utmPrescriptionHdrGUID \
where E.tcreatetime >getdate()-30 and sTempProcName is not null \
and sTempProcName not in ('50C*30','60C*5','60C*30') \
select scardno1,sTempProcName=stuff((select '-'+sTempProcName from #TEMP6 t where sCardNo1=#TEMP6.sCardNo1 for xml path('')), 1, 1, '')  \
INTO #TEMP5 \
from #TEMP6 \
group by sCardNo1 \
SELECT A.sEquipmentgroupNo,A.sEquipmentNo,A.sCardNo,A.nFactInputQty,A.sCustomerName,A.sProductGMWT,A.sMaterialNo,A.sLotColorNo,A.sLotColorName \
,A.tFactStartTime,A.tFactEndTime,A.sWorkingProcedureName,A.sColorCatena \
,case when A.sWorkingProcedureName='染色' then sTempProcName else '' end as sTempProcName \
,A.nMinSS,A.sType,A.sRepairReason \
FROM #TEMP A \
left join #TEMP5 B ON A.scardno=B.scardno1 \
WHERE ISNULL(A.sEquipmentgroupNo,'') <>'' \
ORDER BY A.sEquipmentgroupNo, sEquipmentNo \
DROP TABLE #TEMPTrackJob \
drop table #TEMP \
drop table #TEMP4 \
drop table #TEMP5 \
drop table #TEMP6"