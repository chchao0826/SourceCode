# -*-coding:utf-8-*-

from flask import render_template, Flask, request
from sqlalchemy import or_, and_, create_engine, Table, MetaData, Column, Integer, ForeignKey, DateTime, Numeric, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, query
from sqlalchemy import text
import os
import pypyodbc
import time
import datetime
# 236 连接配置
DEBUG = True
SECRET_KEY = os.urandom(24)

HOSTNAME = '198.168.6.236'
PORT = '1433'
DATANAME = 'WebDataBase'
USERNAME = 'sa'
PASSWORD = 'czlingtai2018'

engine_236 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types=True)

base = declarative_base()

session_236 = sessionmaker(bind=engine_236)
ses_236 = session_236()

# 考勤数据连接
def mdb_conn():
    db_name = 'E:/DataBase/att2000.mdb'
    password = ''
    str = 'Driver={Microsoft Access Driver (*.mdb)};PWD' + password + ";DBQ=" + db_name
    conn = pypyodbc.win_connect_mdb(str)

    return conn

# 考勤机部门
class department(base):
    __tablename__ = 'pbCommonDataDepartment'
    id = Column(Integer, primary_key = True)
    sDeptName = Column(String(40),nullable = True)
    sEmployees = relationship('employee', backref='pbCommonDataEmployee') # 人员关联

    def __str__(self):
        return self.id


# 人员表
class employee(base):
    __tablename__ = 'pbCommonDataEmployee'
    id = Column(Integer, primary_key = True)
    sEmployeeName = Column(String(40),nullable = True)
    ipbCommonDataDepartmentID = Column(Integer, ForeignKey('pbCommonDataDepartment.id')) # 部门关联
    sCheckIns = relationship('checkin', backref='pbCommonDataCheckIn') # 考勤记录关联

    def __str__(self):
        return self.id

# 考勤表
class checkin(base):
    __tablename__ = 'pbCommonDataCheckIn'
    id = Column(Integer, primary_key = True, autoincrement = True)
    tCheckTime = Column(DateTime,nullable = True)
    iEmployeeID = Column(Integer, ForeignKey('pbCommonDataEmployee.id')) # 人员关联

    def __str__(self):
        return self.id

# 查询方法
def mdb_sel(cur, sql):
    try:
        cur.execute(sql)
        return cur.fetchall()
    except:
        return []

# 部门查询
def check_Department():
    conn = mdb_conn()
    cur = conn.cursor()
    sql = "SELECT A.DEPTID, A.DEPTNAME FROM DEPARTMENTS A"
    sel_data = mdb_sel(cur, sql)
    return sel_data

# 人员
def check_employeeName():
    conn = mdb_conn()
    cur = conn.cursor()
    sql = "SELECT A.USERID, A.Name, A.DEFAULTDEPTID FROM USERINFO A"
    sel_data = mdb_sel(cur, sql)
    return sel_data

# 考勤
def check_data():
    conn = mdb_conn()
    cur = conn.cursor()
    sql = "SELECT TOP 5000 A.USERID, A.CHECKTIME FROM CHECKINOUT A ORDER BY A.CHECKTIME DESC"
    sel_data = mdb_sel(cur, sql)
    return sel_data


# 部门增加
def department_add():
    department_var = check_Department()
    for var in department_var:
        insert_dept = department(
            id = var[0],
            sDeptName = var[1],

        )
        if ses_236.query(department).filter(department.id == var[0]).first() is None:
            ses_236.add(insert_dept)
    return ses_236.commit(), ses_236.close()

# 人员添加
def employee_add():
    employee_var = check_employeeName()
    for var in employee_var:
        insert_employee = employee(
            id = var[0],
            sEmployeeName = var[1],
            ipbCommonDataDepartmentID = var[2],
        )
        if ses_236.query(employee).filter(employee.id == var[0]).first() is None:
            ses_236.add(insert_employee)

    return ses_236.commit(),ses_236.close()


# 考勤添加
def check_add():
    check_var = check_data()
    now = datetime.datetime.now()
    for var in check_var:
        timeStruct = var[1].strftime('%Y-%m-%d')
        varTime = datetime.datetime.strptime(timeStruct, '%Y-%m-%d')
        if (now - varTime).days == 3:
            insert_check = checkin(
                iEmployeeID = var[0],
                tCheckTime = var[1],
            )
            if ses_236.query(checkin).filter(and_(checkin.iEmployeeID == var[0],checkin.tCheckTime == var[1])).first() is None:
                ses_236.add(insert_check)
    return ses_236.commit(),ses_236.close()



if __name__ == '__main__':
    # base.metadata.create_all(engine_236)    
    department_add()
    employee_add()
    check_add()
    # employee_add()
    # check_add()
