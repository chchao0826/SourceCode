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


SELECT B.sEquipmentNo,sEquipmentType,C.sWorkCentreName AS sWorkingProcedureNameBig,'Ⱦɫ' AS sWorkingProcedureName
,ROW_NUMBER() OVER(PARTITION BY sWorkCentreName ORDER BY B.sEquipmentNo) AS nRowNumber
INTO #TT2
FROM #TT A
JOIN emEquipment B ON A.machine = B.sEquipmentNo
JOIN pbWorkCentre C ON B.upbWorkCentreGUID = C.uGUID

INSERT INTO [198.168.6.236].[WebDataBase].[dbo].[pbCommonDataEquipment](sEquipmentNo,sEquipmentName,sWorkingProcedureName,sWorkingProcedureNameBig,nRowNumber)
SELECT sEquipmentNo,sEquipmentType,sWorkingProcedureName,sWorkingProcedureNameBig,nRowNumber
FROM #TT2
ORDER BY nRowNumber

DROP TABLE #TT
DROP TABLE #TT2
