#!/usr/bin/env python  
#coding=utf-8  
from config import engine
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy import Table, MetaData, Column, Integer, String, DateTime, NUMERIC, ForeignKey, Boolean, Unicode
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

Session = sessionmaker(bind = engine)

ses = Session()

class department(Base):
    __tablename__ = 'pbCommonDataDepartment'
    __table_args__ = {
        "mysql_charset":"utf8"
    }
    id = Column(Integer, primary_key = True, autoincrement = True)
    sDepartmentNo = Column(String(20), nullable = True)      #部门编号
    sDepartmentName = Column(String(20), nullable = True)      #部门名称
    sSuperiorDepartment = Column(String(20), nullable = True)      #上级部门
    nEmployeeCount = Column(NUMERIC(11,2), nullable = True)      #部门人数
    def __str__(self):
        return self.id

def department_search():
    department_list = []
    for var in ses.query(department).all():
        var_dict = {
            'id' : var.id,
            'sDepartmentNo' : var.sDepartmentNo,
            'sDepartmentName' : var.sDepartmentName,
            'sSuperiorDepartment' : var.sSuperiorDepartment,
            'nEmployeeCount' : var.nEmployeeCount
        }
        department_list.append(var_dict)
    return department_list

if __name__ == '__main__':
    # department_search = department_search()
    for var in department_search():
        for i in var:
            print(i,var[i])