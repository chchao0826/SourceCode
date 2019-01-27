CREATE TABLE pbCommonDataEquipment(
    ID INT PRIMARY KEY IDENTITY(1,1),
    sEquipmentNo NVARCHAR(30),
    sEquipmentName NVARCHAR(30),
    sWorkingProcedureName NVARCHAR(30),
    nRank INT,
    bUsable BIT
)