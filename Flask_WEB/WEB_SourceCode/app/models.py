from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Table, MetaData, Column, Integer, ForeignKey, DateTime, Numeric, String, Boolean
from sqlalchemy.orm import sessionmaker, relationship, query
from flask import Flask, render_template, request
from app.config import engine_236, engine_253
# from config import engine_236, engine_253


base = declarative_base()

session_236 = sessionmaker(bind = engine_236)
session_253 = sessionmaker(bind = engine_253)

ses_236 = session_236()
ses_253 = session_253()

# 机台表
class equipment(base):
    __tablename__ = 'pbCommonDataEquipment'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sEquipmentNo = Column(String(40),nullable = True)
    sEquipmentName = Column(String(40),nullable = True)
    sWorkingProcedureName = Column(String(40),nullable = True)
    nRowNumber = Column(Integer,nullable = True)
    bUsable = Column(Boolean,nullable = True)
    bIsPMKanBan = Column(Boolean,nullable = True)
    def __str__(self):
        return self.id

# 机台状态表
class equipmentStatus(base):
    __tablename__ = 'pbCommonDataEquipmentStatus'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sStatus = Column(String(40),nullable = True)
    sStatusColor = Column(String(40),nullable = True)
    ipbCommonDataEquipmentID = Column(Integer, nullable = True)

    def __str__(self):
        return self.id

# 工段详细数据表
class dataCenter(base):
    __tablename__ = 'pbCommonDataCenter'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sCardNo = Column(String(40),nullable = True)
    sMaterialNo = Column(String(40),nullable = True)
    sColorNo = Column(String(40),nullable = True)
    nFactInputQty = Column(String(40),nullable = True)
    sWorkingProcedureName = Column(String(40),nullable = True)
    tFactStartTime = Column(DateTime,nullable = True)
    tFactEndTime = Column(DateTime,nullable = True)
    sCustomerName = Column(String(40),nullable = True)
    sSalesGroupName = Column(String(40),nullable = True)
    sDelayColor = Column(String(40),nullable = True)
    sRemarkDye = Column(String(40),nullable = True)
    sRemarkQC = Column(String(40),nullable = True)

    def __str__(self):
        return self.id

# 工段WIP的显示
class workingwip(base):
    __tablename__ = 'pbCommonDataWorkingWIP'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sWorkingProcedureName = Column(String(40),nullable = True)
    sCeiling = Column(String(40),nullable = True)

    def __str__(self):
        return self.id
    
# orgatex 
class orgatex(base):
    __tablename__ = 'pbCommonDataORGATEX'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sCardNo = Column(String(40),nullable = True)
    sColorNo = Column(String(40),nullable = True)
    sMaterialNo = Column(String(40),nullable = True)
    sCustomerName = Column(String(40),nullable = True)
    nFactInputQty = Column(Numeric(18,2),nullable = True)
    tStartTime = Column(DateTime,nullable = True)
    tPlanEndTime = Column(DateTime,nullable = True)
    sNowStatus = Column(String(40),nullable = True)
    iEquipmentID = Column(Integer, nullable = True)

    def __str__(self):
        return self.id

# 部门信息表
class department(base):
    __tablename__ = 'pbCommonDataDepartment'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sDeptNo = Column(String(40),nullable = True)
    sDeptName = Column(String(40),nullable = True)
    bIsDayShift = Column(Boolean,nullable = True)
    def __str__(self):
        return self.id

# 人员信息表
class employee(base):
    __tablename__ = 'pbCommonDataEmployee'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sEmployeeName = Column(String(40),nullable = True)
    ipbCommonDataDepartmentID = Column(Integer, nullable = True)
    def __str__(self):
        return self.id

# 考勤出入记录表
class checkin(base):
    __tablename__ = 'pbCommonDataCheckIn'
    id = Column(Integer, primary_key = True, autoincrement = True)
    tCheckTime = Column(DateTime,nullable = True)
    iEmployeeID = Column(Integer, nullable = True)
    
    def __str__(self):
        return self.id

# 染色预排表
class dyeingexpect(base):
    __tablename__ = 'pbCommonDataDyeingExpect'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sEquipmentNo = Column(String(30), nullable = True)
    sCardNo = Column(String(30), nullable = True)
    sColorNo = Column(String(30), nullable = True)
    sMaterialNo = Column(String(30), nullable = True)
    sMaterialLot = Column(String(30), nullable = True)
    tCardTime = Column(DateTime, nullable = True)
    nFactInputQty = Column(Numeric(18,2), nullable = True)
    sCustomerName = Column(String(30), nullable = True)
    sWorkingProcedureName = Column(String(30), nullable = True)
    sWorkingProcedureName_big = Column(String(30), nullable = True)
    sWorkingProcedure_ALL = Column(String(30), nullable = True)
    tFactEndTime = Column(DateTime, nullable = True)
    tExpectTime = Column(DateTime, nullable = True)
    sColor16 = Column(String(30), nullable = True)
    
    def __str__(self):
        return self.id

# 胚布库存
class FPStore(base):
    __tablename__ = 'pbCommonDataFPStore'
    id = Column(Integer, primary_key = True, autoincrement = True)
    tStoreInTime = Column(String(30), nullable = True)
    nStockQty = Column(Numeric(18,2), nullable = True)
    sGrade = Column(String(30), nullable = True)
    sSalesGroupName = Column(String(30), nullable = True)
    sCustomerName = Column(String(30), nullable = True)
    sLocation = Column(String(30), nullable = True)
    
    def __str__(self):
        return self.id

# 成品库存
class STStore(base):
    __tablename__ = 'pbCommonDataSTStore'
    id = Column(Integer, primary_key = True, autoincrement = True)
    tStoreInTime = Column(String(30), nullable = True)
    nStockQty = Column(Numeric(18,2), nullable = True)
    sGrade = Column(String(30), nullable = True)
    sSalesGroupName = Column(String(30), nullable = True)
    sCustomerName = Column(String(30), nullable = True)
    sLocation = Column(String(30), nullable = True)
    def __str__(self):
        return self.id

# 染色看板
class DyeKanBan(base):
    __tablename__ = 'pbCommonDataDyeKanBan'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sType = Column(String(30), nullable = True)
    sEquipmentNo = Column(String(30), nullable = True)
    sCardNo = Column(String(30), nullable = True)
    sRemark = Column(String(30), nullable = True)
    nNextTime = Column(String(30), nullable = True)
    sCustomerName = Column(String(30), nullable = True)
    sColorNo = Column(String(30), nullable = True)
    sMaterialNo = Column(String(30), nullable = True)
    
    def __str__(self):
        return self.id

if __name__ == '__main__':
    base.metadata.create_all(engine_236)
    