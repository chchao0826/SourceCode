
create table #TT (machine nvarchar(20))

insert into #TT values('A001')
insert into #TT values('A002')
insert into #TT values('A003')
insert into #TT values('A004')
insert into #TT values('A007')
insert into #TT values('A006')
insert into #TT values('B007')
insert into #TT values('B008')
insert into #TT values('B009')
insert into #TT values('B010')
--insert into #TT values('C011')
--insert into #TT values('C012')
--insert into #TT values('C013')
--insert into #TT values('C014')
insert into #TT values('C015')
insert into #TT values('C016')
insert into #TT values('C017')
insert into #TT values('C018')
insert into #TT values('C019')
insert into #TT values('C020')
insert into #TT values('D021')
insert into #TT values('D022')
insert into #TT values('D023')
insert into #TT values('D024')
insert into #TT values('E025')
insert into #TT values('E026')
insert into #TT values('E027')
insert into #TT values('E028')
insert into #TT values('E029')
insert into #TT values('E030')
insert into #TT values('E031')




select #TT.machine,A.procedure_no,A.batch_text_01,
case when CONVERT(INT,CASE WHEN ISNUMERIC("Function") = 1 THEN  "Function" ELSE NULL END)=123 then left(right(convert(varchar(20) ,timeRequested),7),5) +' ;' + case when opcallstate=1 then '尚未' else '' end+'取樣' 
when CONVERT(INT,CASE WHEN ISNUMERIC("Function") = 1 THEN  "Function" ELSE NULL END)=146 and timetoopcall=timetonextstep then convert(nvarchar(10),timetoopcall)+'分鐘後取樣' end as scall,
case when timetoopcall+10>timetoend then convert(nvarchar(10),timetoopcall)+'分鐘後出步' end as sout
,timetoopcall as nNextTime
,case when K.sBrandName is null then K.sCustomerName else K.sBrandName end   AS scombineCustomerName
,I.sArtColorNo AS scombineColorno
,I.sLotColorName AS scombineColorname
,I.sMaterialNo  AS scombineMaterialNo
,timeRequested
into #T
from #TT 
left join [198.168.6.197].[ORGATEX].[dbo].[BatchDetail] A WITH(NOLOCK) ON #TT.Machine=A.Machine_No collate Chinese_PRC_CI_AI_WS --所有在染資料
left join [198.168.6.197].[ORGATEX-INTEG].[dbo].[Machinestatus] F  WITH(NOLOCK) on F.DyelotrefNo=A.Batch_Ref_No collate Chinese_PRC_CI_AI_WS
left join [198.168.6.197].[ORGATEX-INTEG].[dbo].[dyelot_QC] G WITH(NOLOCK) on G.DyelotrefNo=A.Batch_Ref_No collate Chinese_PRC_CI_AI_WS
left join [198.168.6.253].[HSWarpERP_NJYY].dbo.psWorkFlowCard H WITH(NOLOCK) ON H.sCardNo=LEFT(A.batch_text_01,10) collate Chinese_PRC_CI_AI_WS
left join [198.168.6.253].[HSWarpERP_NJYY].dbo.vwsdOrder I WITH(NOLOCK) ON H.usdOrderLotGUID = I.usdOrderLotGUID
left join  [198.168.6.253].[HSWarpERP_NJYY].dbo.pbCustomer K WITH(NOLOCK) ON I.upbCustomerGUID=K.uGUID and K.bUsable='1'
left join (select batch_ref_no,sum(case when AlarmGroup=1 then 1 else 0 end) as Alarmcount
from  [198.168.6.197].[ORGATEX].[dbo].[MachineProtocol] WITH(NOLOCK)
where logtimestamp >=  (CONVERT(NVARCHAR(10), DATEADD(DD, -3, GETDATE()), 120)+' 8:00' )
group by batch_ref_no) J on J.batch_ref_no=A.Batch_Ref_No
where A.started is not null and A.terminated is null 
order by A.machine_no

select machine AS sEquipmentNo
,case when batch_text_01 like '2019%' or batch_text_01 like '2018%'  then '洗缸' else  batch_text_01 end  as sCardNo
,case when scall is null then sout else scall end as sRemark
,nNextTime,scombineCustomerName AS sCustomerName 
,scombineColorno AS sColorNo,scombineMaterialNo AS sMaterialNo
INTO #TEMP
from #T
where scall is not null or sout is not null and  convert(decimal(18,2),nNextTime) <15
order by case when scall like '%後%' or sout  like '%後%' then null else timeRequested end DESC, convert(decimal(18,2),nNextTime) 

SELECT A.*,B.id
INTO #TEMP1
FROM #TEMP A
LEFT JOIN [dbo].[pbCommonDataDyeKanBan] B ON A.sEquipmentNo = B.sEquipmentNo collate Chinese_PRC_CI_AI_WS AND A.sCardNo = B.sCardNo collate Chinese_PRC_CI_AI_WS


DELETE  [dbo].[pbCommonDataDyeKanBan]
WHERE id NOT IN (SELECT id FROM #TEMP1) AND sType = '取样'

INSERT INTO [dbo].[pbCommonDataDyeKanBan](sType,sEquipmentNo,sCardNo,sRemark,nNextTime,sCustomerName,sColorNo,sMaterialNo)
SELECT '取样',sEquipmentNo,sCardNo,sRemark,nNextTime,sCustomerName,sColorNo,sMaterialNo
FROM #TEMP1
WHERE id IS NULL

UPDATE [dbo].[pbCommonDataDyeKanBan]
SET sRemark = B.sRemark
,nNextTime = B.nNextTime
FROM [dbo].[pbCommonDataDyeKanBan] A
JOIN #TEMP1 B ON A.sEquipmentNo = B.sEquipmentNo collate Chinese_PRC_CI_AI_WS AND A.sCardNo = B.sCardNo collate Chinese_PRC_CI_AI_WS
WHERE B.id IS NOT NULL AND sType = '取样'


SELECT *FROM [dbo].[pbCommonDataDyeKanBan]


DROP TABLE #TEMP
DROP TABLE #TEMP1
drop table #TT
drop table #T



