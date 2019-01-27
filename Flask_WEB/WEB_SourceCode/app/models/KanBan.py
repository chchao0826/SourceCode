from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Table, MetaData, Column, Integer, ForeignKey, DateTime, Numeric, String, Boolean
from sqlalchemy.orm import sessionmaker, relationship, query
from flask import Flask, render_template, request
from app.config import engine

base = declarative_base()

session = sessionmaker(bind = engine)

ses = session()

# 机台表
class equipment(base):
    __tablename__ = 'pbCommonDataEquipment'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sEquipmentNo = Column(String(40),nullable = True)
    sEquipmentName = Column(String(40),nullable = True)
    sWorkingProcedureName = Column(String(40),nullable = True)
    nRank = Column(Integer,nullable = True)
    bUsable = Column(Boolean,nullable = True)
    
    def __str__(self):
        return self.id

# 工段表
class WorkingProcedure(base):
    __tablename__ = 'pbCommonDataWorkingProcedure'
    id = Column(Integer, primary_key = True, autoincrement = True)
    sWorkingProcedureName = Column(String(40),nullable = True)
    nUpper = Column(Integer,nullable = True)
    
    def __str__(self):
        return self.id


if __name__ == '__main__':
    base.metadata.create_all(engine)
