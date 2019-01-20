sqlGroup = " select sRemark,\
nDiffPrintingCleanWater+nDiffPrintingSoftWater AS nDiffPrintingWater,\
nDiffRefineMachineWater+nDiffRefineMachine2Water as nDiffRefineMachineWater,\
nDiffFinishWater,nDiffLifeWater,\
nDiffDirtyWater-nDiffPrintingCleanWater-nDiffPrintingSoftWater-nDiffRefineMachineWater-nDiffRefineMachine2Water-nDiffFinishWater-nDiffLifeWater-nDiffLabWater-nDiffWaterReturnToSoftWater-nDiffWaterToSoftWater as  nDiffsDyeingWater,\
nDiffPrintingCleanWater-nDiffDyeingCleanWaterSub AS nDiffPrintingCleanWater,\
nDiffDyeingHotWater,\
nDiffDyeingSoftWater-nDiffLabWater-nDiffOiLWater-nDiffOiLHotWater - nDiffFinishWater - nDiffPrintingSoftWater+nDiffDyeingHotWater AS nDiffDyeingWater,\
nDiffHotWater,nDiffColdWater,\
CONVERT(NVARCHAR(10),CONVERT(INT,nDiffHotWater/CASE WHEN ISNULL(nDiffColdWater,0) = 0 THEN 1 ELSE nDiffColdWater END *100))+'%' AS sColdWaterPre,\
nDiffPrintingSoftWater-nDiffLabCloSoftWater AS nDiffPrintingSoftWater,\
CASE WHEN dReportDate >='2018-08-01' THEN nDiffCoolingTower1 ELSE nDiffOiLWater2 END AS nDiffCoolingTower1,\
nDiffOiLWater AS  nOiLWater,\
nDiffOfficeWater,nDiffPrintingHotWater,nDiffTotalWater,nDiffDirtyWater,nDiffSteam,nDiffPrintingSteam,\
nDiffMachine1Steam+nDiffMachine2Steam as  nDiffMachine,\
nDiffPrintingGas,nDiffTotalElectricity,\
CASE WHEN tcreatetime <'2017-07-01' THEN nDiffPrintingElectricity ELSE nDiffPrintingElectricity-nDiffDyeing1ElectricitySub END AS nDiffPrintingElectricity,\
nDiffWeaveElectricity+ISNULL(nDiffWeaveElectricity2,0) AS nDiffWeaveElectricity,\
nDiffRefineMachineElectricity+nDiffRefineMachine2Electricity AS nDiffRefineMachineElectricity,\
nDiffFinish1Electricity+nDiffFinish2Electricity+nDiffFinish3Electricity+nDiffFinish4Electricity+nDiffFinish5Electricity AS nDiffFinish1Electricity,\
nDiffDyeing1Electricity+nDiffDyeing2Electricity-isnull(nDiffLabElectricity,0) AS nDyeingElectricity,\
nDiffWaterTreatmentElectricity AS nDiffWaterTreatmentElectricity, \
nDiffLabElectricity,\
ISNULL(nDiffWarpingSouthElectricity,0)+ISNULL(nDiffWarpingNorthElectricity,0) AS nDiffWarpingElectricity ,\
DATEADD(DAY,-1,dReportDate) AS dReportDate \
INTO #TEMP \
from pbCommonOutPutAndEnergyHdrLT with (nolock) \
WHERE DATEDIFF(MONTH,dReportDate,GETDATE()) < 6 \
select \
convert(nvarchar(7),dReportDate,120) as ReportDate,\
sum(nDiffPrintingWater) as nDiffPrintingWater,\
sum(nDiffRefineMachineWater) as nDiffRefineMachineWater,\
sum(nDiffFinishWater) as nDiffFinishWater,\
sum(nDiffLifeWater) as nDiffLifeWater,\
sum(nDiffsDyeingWater) as nDiffsDyeingWater,\
SUM(nDiffPrintingCleanWater) AS nDiffPrintingCleanWater,\
SUM(nDiffDyeingHotWater) AS nDiffDyeingHotWater,\
SUM(nDiffDyeingWater) AS nDiffDyeingWater,\
SUM(nDiffHotWater) AS nDiffHotWater,\
SUM(nDiffColdWater) AS nDiffColdWater,\
SUM(nDiffPrintingSoftWater) AS nDiffPrintingSoftWater,\
SUM(nDiffPrintingHotWater) AS nDiffPrintingHotWater,\
SUM(nDiffOfficeWater) AS nDiffOfficeWater,\
SUM(nDiffCoolingTower1) AS nDiffCoolingTower1,\
sum(nDiffTotalWater) as nDiffTotalWater,\
sum(nDiffDirtyWater) as nDiffDirtyWater,\
sum(nDiffSteam) as nDiffSteam,\
sum(nDiffPrintingSteam) as nDiffPrintingSteam,\
sum(nDiffMachine) as nDiffMachine,\
SUM(nDiffPrintingGas) AS nDiffPrintingGas,\
sum(nDiffTotalElectricity) as nDiffTotalElectricity,\
sum(nDiffPrintingElectricity) as nDiffPrintingElectricity,\
sum(nDiffWeaveElectricity) as nDiffWeaveElectricity,\
sum(nDiffRefineMachineElectricity) as nDiffRefineMachineElectricity,\
sum(nDiffFinish1Electricity) as nDiffFinish1Electricity,\
sum(nDyeingElectricity) as nDyeingElectricity,\
sum(nDiffWaterTreatmentElectricity) AS nDiffWaterTreatmentElectricity,\
SUM(nDiffLabElectricity) AS nDiffLabElectricity,\
SUM( nDiffWarpingElectricity) AS nDiffWarpingElectricity,\
SUM( nOiLWater) AS nOiLWater \
into #TT \
from #TEMP with (nolock) \
group by convert(nvarchar(7),dReportDate,120) \
select *FROM #TT \
DROP TABLE #TEMP \
DROP TABLE #TT"