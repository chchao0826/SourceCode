create table #TT (machine nvarchar(20))

insert into #TT values('A001')
insert into #TT values('A002')
insert into #TT values('A003')
insert into #TT values('A004')
insert into #TT values('A005')
insert into #TT values('A006')
insert into #TT values('B007')
insert into #TT values('B008')
insert into #TT values('B009')
insert into #TT values('B010')
--insert into #TT values('C012')
--insert into #TT values('C013')
--insert into #TT values('C014')
--insert into #TT values('C015')
insert into #TT values('C016')
insert into #TT values('C017')
insert into #TT values('C018')
insert into #TT values('C019')
insert into #TT values('C020')
insert into #TT values('D021')
insert into #TT values('D022')
insert into #TT values('D023')
insert into #TT values('D024')
insert into #TT values('E011')
insert into #TT values('E025')
insert into #TT values('E026')
insert into #TT values('E027')
insert into #TT values('E028')
insert into #TT values('E029')
insert into #TT values('E030')
insert into #TT values('E031')

select A.machine_no,A.procedure_no,A.started
,(A.times_02)/60 as realtime,F.timetoend,
DATEADD(MINUTE,timetoend,A.started) AS tPlanEndTime
,case when "function"='146' then convert(nvarchar(20),'降溫') 
when "function"='721' then '升溫' 
when "function"='123' then'取樣' 
when "function"='141' then '溫控' 
when "function"='861' then '排水'
else NULL end as sNowStatus
,CASE WHEN A.procedure_no=999 then '洗缸' ELSE A.batch_text_01 END AS sCardNo
,C.batch_text_01 as sNextCardNo1
,D.batch_text_01 as sNextCardNo2
into #TT2
from  [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] A WITH(NOLOCK)  --所有在染資料
left join [198.168.6.197].[ORGATEX].[dbo].[BatchChain] B WITH(NOLOCK) ON B.MachineNo=A.Machine_No  AND B.PREV =''
left join [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] C WITH(NOLOCK) on B.BatchRefNo=C.batch_ref_no 
left join [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] D WITH(NOLOCK) on B.next=D.batch_ref_no
left join [198.168.6.197].[ORGATEX-INTEG].[dbo].[Machinestatus] F  WITH(NOLOCK) on F.DyelotrefNo=A.Batch_Ref_No collate Chinese_PRC_CI_AI_WS
left join [198.168.6.197].[ORGATEX-INTEG].[dbo].[dyelot_QC] G WITH(NOLOCK) on G.DyelotrefNo=A.Batch_Ref_No collate Chinese_PRC_CI_AI_WS
left join (select batch_ref_no,sum(case when AlarmGroup=1 then 1 else 0 end) as Alarmcount
from  [198.168.6.197].[ORGATEX].[dbo].[MachineProtocol]
where logtimestamp >=  (CONVERT(NVARCHAR(10), DATEADD(DD, -3, GETDATE()), 120)+' 8:00' )
group by batch_ref_no) J on J.batch_ref_no=A.Batch_Ref_No
where  A.started is not null and A.terminated is null	



SELECT id AS id,sEquipmentNo AS sEquipmentNo,sEquipmentName AS sEquipmentName
,sWorkingProcedureName AS sWorkingProcedureName
,sWorkingProcedureNameBig AS sWorkingProcedureNameBig
,bUsable AS bUsable
INTO #TT3
FROM [WebDataBase].[dbo].[pbCommonDataEquipment]
WHERE sWorkingProcedureName = '染色' AND ISNULL(bUsable,0) <> 1


SELECT A.id AS iEquipmentID,B.sCardNo,B.started AS tStartTime,B.tPlanEndTime,B.sNowStatus
,CONVERT(NVARCHAR(50),NULL) AS sColorNo
,CONVERT(NVARCHAR(50),NULL)  AS sMaterialNo
,CONVERT(NVARCHAR(50),NULL)  AS sCustomerName
,CONVERT(decimal(18,2),NULL)  AS nFactInputQty
,CONVERT(uniqueidentifier,NULL) AS upsWorkFlowCardGUID
INTO #TT4
FROM #TT3 A
left join #TT2 B ON A.sEquipmentNo = B.Machine_No collate Chinese_PRC_CI_AI_WS

INSERT INTO #TT4(iEquipmentID,sCardNo)
SELECT A.id,B.sNextCardNo1
FROM #TT3 A
left join #TT2 B ON A.sEquipmentNo = B.Machine_No collate Chinese_PRC_CI_AI_WS

INSERT INTO #TT4(iEquipmentID,sCardNo)
SELECT A.id,B.sNextCardNo2
FROM #TT3 A
left join #TT2 B ON A.sEquipmentNo = B.Machine_No collate Chinese_PRC_CI_AI_WS

UPDATE #TT4
SET sColorNo = D.sColorNo,
sMaterialNo = E.sMaterialNo,
sCustomerName = C.sCustomerName,
nFactInputQty = B.nFactInputQty,
upsWorkFlowCardGUID = B.uGUID
FROM #TT4 A
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].psWorkFlowCard B ON A.sCardNo = B.sCardNo collate Chinese_PRC_CI_AI_WS
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].vwsdOrder C ON B.usdOrderLotGUID = C.usdOrderLotGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].tmColor D ON D.uGUID = B.utmColorGUID
LEFT JOIN [198.168.6.253].[HSWarpERP_NJYY].[dbo].mmMaterial E ON E.uGUID = B.ummMaterialGUID



-- 删除老数据 插入新数据
DELETE  [WebDataBase].[dbo].[pbCommonDataORGATEX]

-- 插入新数据
INSERT INTO [WebDataBase].[dbo].[pbCommonDataORGATEX](
sCardNo,sColorNo,sMaterialNo,sCustomerName,nFactInputQty,tStartTime,tPlanEndTime,sNowStatus,iEquipmentID,upsWorkFlowCardGUID
)

SELECT sCardNo,sColorNo,sMaterialNo,sCustomerName,nFactInputQty,tStartTime,tPlanEndTime,sNowStatus,iEquipmentID,upsWorkFlowCardGUID
FROM #TT4




drop table #TT
drop table #TT2
drop table #TT3
drop table #TT4

