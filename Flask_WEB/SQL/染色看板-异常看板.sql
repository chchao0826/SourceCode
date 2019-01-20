
--顯示準備
--檢查中檢最近的兩缸，是否存在勾紗
select B.*,E.uGUID as upsWorkFlowCardGUID,utmColorGUID,convert(nvarchar(20),null) as smachine 
into #TTT 
from  [198.168.6.253].[HSWarpERP_NJYY].dbo.pbCommonDataQmTest B WITH(NOLOCK)  
left join  [198.168.6.253].[HSWarpERP_NJYY].dbo.psWorkFlowCard E WITH(NOLOCK)  ON B.sCardNo=E.sCardNo
where icommontype='1008' and B.tCreateTime>getdate()-2 

update #TTT
set smachine=B.sEquipmentNo
from #TTT E
join [198.168.6.253].[HSWarpERP_NJYY].dbo.ppTrackJob A WITH(NOLOCK) ON A.upsWorkFlowCardGUID=E.upsWorkFlowCardGUID and A.upbWorkingProcedureGUID='2897314A-D914-40CF-B7D1-A4A301149E40' 
join [198.168.6.253].[HSWarpERP_NJYY].dbo.emEquipment B WITH(NOLOCK) ON A.uemEquipmentGUID=B.uGUID

select ROW_NUMBER() over(partition by smachine order by tCreateTime desc) as ncount,* into #TTTT from #TTT   order by smachine
select DISTINCT smachine
,left(right(convert(char(20),tCreateTime,20),12),8) as tCreateTime,sMaterialNo,sRepairReason 
INTO #TTTTT
from #TTTT where ncount<3 
and sRepairReason like '%勾纱%'

SELECT A.*,B.ID
INTO #TT
FROM #TTTTT A
LEFT JOIN [dbo].[pbCommonDataDyeKanBan] B ON A.smachine = B.sEquipmentNo AND A.sMaterialNo = B.sMaterialNo


DELETE  [dbo].[pbCommonDataDyeKanBan]
WHERE id NOT IN (SELECT id FROM #TT) AND sType = '异常'

INSERT INTO [dbo].[pbCommonDataDyeKanBan](sType,sEquipmentNo,sRemark,sMaterialNo)
SELECT '异常',smachine,sRepairReason,sMaterialNo
FROM #TT
WHERE id IS NULL

UPDATE [dbo].[pbCommonDataDyeKanBan]
SET sRemark = B.sRepairReason
FROM [dbo].[pbCommonDataDyeKanBan] A
JOIN #TT B ON A.sEquipmentNo = B.smachine collate Chinese_PRC_CI_AI_WS AND A.sMaterialNo = B.sMaterialNo collate Chinese_PRC_CI_AI_WS
WHERE B.id IS NOT NULL AND sType = '异常'


SELECT *FROM [dbo].[pbCommonDataDyeKanBan]

drop table #TT
drop table #TTT
drop table #TTTT
drop table #TTTTT
