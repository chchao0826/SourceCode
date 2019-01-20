
select
sRemark,

--印花总用水=印花清水+印花软水
nDiffPrintingCleanWater+nDiffPrintingSoftWater AS nDiffPrintingWater,

--水洗用水= 水洗1+水洗2
nDiffRefineMachineWater+nDiffRefineMachine2Water as nDiffRefineMachineWater,

--定型用水=定型用水
nDiffFinishWater,

--生活用水=生活用水
nDiffLifeWater,

--染色用水=总污水-印花清水-印花软水-水洗1用水-水洗2用水-定型用水-生活用水-化验室用水-软化用水-逆滲透水
nDiffDirtyWater-nDiffPrintingCleanWater-nDiffPrintingSoftWater-nDiffRefineMachineWater-nDiffRefineMachine2Water-nDiffFinishWater-nDiffLifeWater-nDiffLabWater-nDiffWaterReturnToSoftWater-nDiffWaterToSoftWater as  nDiffsDyeingWater,

--印花清水:印花清水总表-染厂清水分表  (20170706新增)
nDiffPrintingCleanWater-nDiffDyeingCleanWaterSub AS nDiffPrintingCleanWater,

--染色用热水
nDiffDyeingHotWater,

----染色用水=染色软水-化验用水-静水除尘-静电除尘2+染色热水
--nDiffDyeingSoftWater-nDiffLabWater-nDiffOiLWater-nDiffOiLHotWater+nDiffDyeingHotWater AS nDiffDyeingWater,

--染色用水=染色软水-化验用水-静水除尘-静电除尘2+染色热水-印花软水-定型用水
nDiffDyeingSoftWater-nDiffLabWater-nDiffOiLWater-nDiffOiLHotWater - nDiffFinishWater - nDiffPrintingSoftWater+nDiffDyeingHotWater AS nDiffDyeingWater,

--热水
nDiffHotWater,
--总回收热水
nDiffColdWater,

CONVERT(NVARCHAR(10),CONVERT(INT,nDiffHotWater/CASE WHEN ISNULL(nDiffColdWater,0) = 0 THEN 1 ELSE nDiffColdWater END *100))+'%' AS sColdWaterPre,

--印花软水=印花软水-化验成衣软水		(20170706新增)
nDiffPrintingSoftWater-nDiffLabCloSoftWater AS nDiffPrintingSoftWater,

--冷却塔用水--静电除尘1
CASE WHEN dReportDate >='2018-08-01' THEN nDiffCoolingTower1 ELSE nDiffOiLWater2 END AS nDiffCoolingTower1, 

--静电除尘2
nDiffOiLWater AS  nOiLWater,

--办公楼用水
nDiffOfficeWater,

--印花热水
nDiffPrintingHotWater,

--总用水差異
nDiffTotalWater,

--污水差异
nDiffDirtyWater,

--总蒸气
nDiffSteam,

--印花蒸气
nDiffPrintingSteam,

----染厂蒸气=蒸氣差異-印花蒸氣差異
--nDiffSteam-nDiffPrintingSteam as nDiffDye ,

--天然气=天然氣1差異+天然氣2差異
nDiffMachine1Steam+nDiffMachine2Steam as  nDiffMachine,

--印花天然气(20170706新增)
nDiffPrintingGas,

--总用电
nDiffTotalElectricity,

--印花用电 
--七月一号之后的使用:印花用电=印花用电-染色电表分表
CASE WHEN tcreatetime <'2017-07-01' THEN nDiffPrintingElectricity ELSE nDiffPrintingElectricity-nDiffDyeing1ElectricitySub END AS nDiffPrintingElectricity,

--织厂用电
nDiffWeaveElectricity+ISNULL(nDiffWeaveElectricity2,0) AS nDiffWeaveElectricity,

--水洗用电=水洗1用电+水洗2用电
nDiffRefineMachineElectricity+nDiffRefineMachine2Electricity AS nDiffRefineMachineElectricity,

--定型用电=定型1+定型2+定型3+定型4+定型5
nDiffFinish1Electricity+nDiffFinish2Electricity+nDiffFinish3Electricity+nDiffFinish4Electricity+nDiffFinish5Electricity AS nDiffFinish1Electricity,

--染色用电=染色1+染色2扣化验室用电
nDiffDyeing1Electricity+nDiffDyeing2Electricity-isnull(nDiffLabElectricity,0) AS nDyeingElectricity,

--染厂及印花厂公共用电
nDiffWaterTreatmentElectricity AS nDiffWaterTreatmentElectricity, 

--化验室用电
nDiffLabElectricity,

ISNULL(nDiffWarpingSouthElectricity,0)+ISNULL(nDiffWarpingNorthElectricity,0) AS nDiffWarpingElectricity ,


screator,
tcreatetime,
DATEADD(DAY,-1,dReportDate) AS dReportDate,
bPrintingCleanWaterIsOK,
bPrintingSoftWaterIsOK,
bWaterToSoftWaterIsOK,
bWaterReturnToSoftWaterIsOK,
bRefineMachineWaterIsOK,
bRefineMachine2WaterIsOK,
bFinishWaterIsOK,
bLifeWaterIsOK,
bLabWaterIsOK,
bcleanWaterIsOK,
bCombineDyeingWaterIsOK,
bDyeingSoftWaterIsOK,
bDyeingHotWaterIsOK,
bHotWaterIsOK,
bColdWaterIsOK,
bTotalWaterIsOK,
bDirtyWaterIsOK,
bOiLWaterIsOK,
bOiLWater2IsOK,
bDirtyWaterIsRain,
bOfficeWaterIsOK,
bCoolingTowerIsOK
INTO #TEMP
from pbCommonOutPutAndEnergyHdrLT with(nolock)


SELECT dReportDate,sRemark,--备注
nDiffPrintingWater,nDiffRefineMachineWater,nDiffFinishWater,nDiffLifeWater,nDiffsDyeingWater,nDiffPrintingCleanWater
,nDiffDyeingHotWater,nDiffDyeingWater,nDiffHotWater,nDiffColdWater,sColdWaterPre
,nDiffPrintingSoftWater,nDiffPrintingHotWater,nDiffTotalWater,nDiffDirtyWater
,nDiffSteam,nDiffPrintingSteam,nDiffMachine,nDiffPrintingGas
,nDiffTotalElectricity,nDiffPrintingElectricity,nDiffWeaveElectricity,nDiffRefineMachineElectricity,nDiffFinish1Electricity,nDyeingElectricity,
nDiffWaterTreatmentElectricity,nDiffLabElectricity, nOiLWater,nDiffOfficeWater,nDiffCoolingTower1,
nDiffWarpingElectricity,
--印花总用水颜色底色
nDiffPrintingWater_BGCOLOR=CASE WHEN bPrintingCleanWaterIsOK=1 OR bPrintingSoftWaterIsOK=1 THEN 65535 ELSE NULL END,
--水洗用水颜色底色
nDiffRefineMachineWater_BGCOLOR=CASE WHEN bRefineMachine2WaterIsOK=1 OR bRefineMachineWaterIsOK=1 THEN 65535 ELSE NULL END,
--定型用水颜色底色
nDiffFinishWater_BGCOLOR=CASE WHEN bFinishWaterIsOK=1 THEN 65535 ELSE NULL END,
--生活用水颜色底色
nDiffLifeWater_BGCOLOR=CASE WHEN bLifeWaterIsOK=1 THEN 65535 ELSE NULL END,
--染色用水颜色底色
nDiffsDyeingWater_BGCOLOR=CASE WHEN bDirtyWaterIsOK=1 OR bPrintingCleanWaterIsOK=1 OR bPrintingSoftWaterIsOK=1 OR bRefineMachineWaterIsOK=1 OR bRefineMachine2WaterIsOK=1 OR bFinishWaterIsOK=1 OR bLifeWaterIsOK=1 OR bLabWaterIsOK=1 THEN 65535 ELSE NULL END,
--总用水颜色底色
nDiffTotalWater_BGCOLOR=CASE WHEN bTotalWaterIsOK=1 THEN 65535 ELSE NULL END,
--总污水颜色底色
nDiffDirtyWater_BGCOLOR=CASE WHEN bDirtyWaterIsOK=1 THEN 65535 ELSE NULL END,
--下雨天备注底色
nDiffOfficeWater_BGCOLOR=CASE WHEN bOfficeWaterIsOK=1 THEN 65535 ELSE NULL END,
--
nDiffCoolingTower1_BGCOLOR=CASE WHEN bCoolingTowerIsOK=1 THEN 65535 ELSE NULL END,
--下雨天备注底色
sRemark_BGCOLOR=CASE WHEN bDirtyWaterIsRain=1 THEN 13467442 ELSE NULL END
FROM #TEMP

where DATEDIFF(DAY,dReportDate,GETDATE()) <= 30
order by dReportDate DESC


--汇总
select 
convert(nvarchar(7),dReportDate,120) as ReportDate,
sum(nDiffPrintingWater) as nDiffPrintingWater,
sum(nDiffRefineMachineWater) as nDiffRefineMachineWater,
sum(nDiffFinishWater) as nDiffFinishWater,
sum(nDiffLifeWater) as nDiffLifeWater,
sum(nDiffsDyeingWater) as nDiffsDyeingWater,
SUM(nDiffPrintingCleanWater) AS nDiffPrintingCleanWater
,SUM(nDiffDyeingHotWater) AS nDiffDyeingHotWater
,SUM(nDiffDyeingWater) AS nDiffDyeingWater
,SUM(nDiffHotWater) AS nDiffHotWater
,SUM(nDiffColdWater) AS nDiffColdWater
,SUM(nDiffPrintingSoftWater) AS nDiffPrintingSoftWater,
SUM(nDiffPrintingHotWater) AS nDiffPrintingHotWater,
SUM(nDiffOfficeWater) AS nDiffOfficeWater,
SUM(nDiffCoolingTower1) AS nDiffCoolingTower1,
sum(nDiffTotalWater) as nDiffTotalWater,
sum(nDiffDirtyWater) as nDiffDirtyWater,
sum(nDiffSteam) as nDiffSteam,
sum(nDiffPrintingSteam) as nDiffPrintingSteam,
sum(nDiffMachine) as nDiffMachine,
SUM(nDiffPrintingGas) AS nDiffPrintingGas,
sum(nDiffTotalElectricity) as nDiffTotalElectricity,
sum(nDiffPrintingElectricity) as nDiffPrintingElectricity,
sum(nDiffWeaveElectricity) as nDiffWeaveElectricity,
sum(nDiffRefineMachineElectricity) as nDiffRefineMachineElectricity,
sum(nDiffFinish1Electricity) as nDiffFinish1Electricity,
sum(nDyeingElectricity) as nDyeingElectricity,
sum(nDiffWaterTreatmentElectricity) AS nDiffWaterTreatmentElectricity
,SUM(nDiffLabElectricity) AS nDiffLabElectricity
,SUM( nDiffWarpingElectricity) AS nDiffWarpingElectricity
,SUM( nOiLWater) AS  nOiLWater
into #TT
from #TEMP with (nolock)
group by convert(nvarchar(7),dReportDate,120)

select *FROM #TT

DROP TABLE #TEMP
DROP TABLE #TT









