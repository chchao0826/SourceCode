sql = "select sRemark,\
nDiffPrintingCleanWater+nDiffPrintingSoftWater AS nDiffPrintingWater,\
nDiffRefineMachineWater+nDiffRefineMachine2Water as nDiffRefineMachineWater,\
nDiffFinishWater,\
nDiffLifeWater,\
nDiffDirtyWater-nDiffPrintingCleanWater-nDiffPrintingSoftWater-nDiffRefineMachineWater-nDiffRefineMachine2Water-nDiffFinishWater-nDiffLifeWater-nDiffLabWater-nDiffWaterReturnToSoftWater-nDiffWaterToSoftWater as nDiffsDyeingWater,\
nDiffPrintingCleanWater-nDiffDyeingCleanWaterSub AS nDiffPrintingCleanWater,\
nDiffDyeingHotWater,\
nDiffDyeingSoftWater-nDiffLabWater-nDiffOiLWater-nDiffOiLHotWater - nDiffFinishWater - nDiffPrintingSoftWater+nDiffDyeingHotWater AS nDiffDyeingWater,\
nDiffHotWater,\
nDiffColdWater,\
CONVERT(NVARCHAR(10),CONVERT(INT,nDiffHotWater/CASE WHEN ISNULL(nDiffColdWater,0) = 0 THEN 1 ELSE nDiffColdWater END *100))+'%' AS sColdWaterPre,\
nDiffPrintingSoftWater-nDiffLabCloSoftWater AS nDiffPrintingSoftWater,\
CASE WHEN dReportDate >='2018-08-01' THEN nDiffCoolingTower1 ELSE nDiffOiLWater2 END AS nDiffCoolingTower1, \
nDiffOiLWater AS  nOiLWater,\
nDiffOfficeWater,\
nDiffPrintingHotWater,\
nDiffTotalWater,\
nDiffDirtyWater,\
nDiffSteam,\
nDiffPrintingSteam,\
nDiffMachine1Steam+nDiffMachine2Steam as  nDiffMachine,\
nDiffPrintingGas,\
nDiffTotalElectricity,\
CASE WHEN tcreatetime <'2017-07-01' THEN nDiffPrintingElectricity ELSE nDiffPrintingElectricity-nDiffDyeing1ElectricitySub END AS nDiffPrintingElectricity,\
nDiffWeaveElectricity+ISNULL(nDiffWeaveElectricity2,0) AS nDiffWeaveElectricity,\
nDiffRefineMachineElectricity+nDiffRefineMachine2Electricity AS nDiffRefineMachineElectricity,\
nDiffFinish1Electricity+nDiffFinish2Electricity+nDiffFinish3Electricity+nDiffFinish4Electricity+nDiffFinish5Electricity AS nDiffFinish1Electricity,\
nDiffDyeing1Electricity+nDiffDyeing2Electricity-isnull(nDiffLabElectricity,0) AS nDyeingElectricity,\
nDiffWaterTreatmentElectricity AS nDiffWaterTreatmentElectricity, \
nDiffLabElectricity,\
ISNULL(nDiffWarpingSouthElectricity,0)+ISNULL(nDiffWarpingNorthElectricity,0) AS nDiffWarpingElectricity ,\
screator,tcreatetime,DATEADD(DAY,-1,dReportDate) AS dReportDate,bPrintingCleanWaterIsOK,bPrintingSoftWaterIsOK,bWaterToSoftWaterIsOK,bWaterReturnToSoftWaterIsOK,\
bRefineMachineWaterIsOK,bRefineMachine2WaterIsOK,bFinishWaterIsOK,bLifeWaterIsOK,bLabWaterIsOK,bcleanWaterIsOK,bCombineDyeingWaterIsOK,\
bDyeingSoftWaterIsOK,bDyeingHotWaterIsOK,bHotWaterIsOK,bColdWaterIsOK,bTotalWaterIsOK,bDirtyWaterIsOK,bOiLWaterIsOK,bOiLWater2IsOK,bDirtyWaterIsRain,\
bOfficeWaterIsOK,bCoolingTowerIsOK \
INTO #TEMP \
from pbCommonOutPutAndEnergyHdrLT with(nolock) \
SELECT dReportDate,sRemark,\
nDiffPrintingWater,nDiffRefineMachineWater,nDiffFinishWater,nDiffLifeWater,nDiffsDyeingWater,nDiffPrintingCleanWater\
,nDiffDyeingHotWater,nDiffDyeingWater,nDiffHotWater,nDiffColdWater,sColdWaterPre\
,nDiffPrintingSoftWater,nDiffPrintingHotWater,nDiffTotalWater,nDiffDirtyWater\
,nDiffSteam,nDiffPrintingSteam,nDiffMachine,nDiffPrintingGas\
,nDiffTotalElectricity,nDiffPrintingElectricity,nDiffWeaveElectricity,nDiffRefineMachineElectricity,nDiffFinish1Electricity,nDyeingElectricity,\
nDiffWaterTreatmentElectricity,nDiffLabElectricity, nOiLWater,nDiffOfficeWater,nDiffCoolingTower1,nDiffWarpingElectricity,\
nDiffPrintingWater_BGCOLOR=CASE WHEN bPrintingCleanWaterIsOK=1 OR bPrintingSoftWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffRefineMachineWater_BGCOLOR=CASE WHEN bRefineMachine2WaterIsOK=1 OR bRefineMachineWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffFinishWater_BGCOLOR=CASE WHEN bFinishWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffLifeWater_BGCOLOR=CASE WHEN bLifeWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffsDyeingWater_BGCOLOR=CASE WHEN bDirtyWaterIsOK=1 OR bPrintingCleanWaterIsOK=1 OR bPrintingSoftWaterIsOK=1 OR bRefineMachineWaterIsOK=1 OR bRefineMachine2WaterIsOK=1 OR bFinishWaterIsOK=1 OR bLifeWaterIsOK=1 OR bLabWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffTotalWater_BGCOLOR=CASE WHEN bTotalWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffDirtyWater_BGCOLOR=CASE WHEN bDirtyWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffOfficeWater_BGCOLOR=CASE WHEN bOfficeWaterIsOK=1 THEN 65535 ELSE NULL END,\
nDiffCoolingTower1_BGCOLOR=CASE WHEN bCoolingTowerIsOK=1 THEN 65535 ELSE NULL END,\
sRemark_BGCOLOR=CASE WHEN bDirtyWaterIsRain=1 THEN 13467442 ELSE NULL END \
FROM #TEMP \
where DATEDIFF(DAY,dReportDate,GETDATE()) <= 30 \
order by dReportDate DESC \
DROP TABLE #TEMP"
