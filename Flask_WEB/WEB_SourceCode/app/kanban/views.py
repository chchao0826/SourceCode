# -*-coding:utf-8-*-
from . import KanBan
from flask import render_template, Flask, request
from app.views.KanBan import emStatus, wpStatus, StoreStatus


import json

# 主页
@KanBan.route('/')
def index():
    return render_template('KanBan/base.html')

# 工厂平面图
@KanBan.route('/工厂平面图/')
def FloorPlan():
    statusVar = emStatus()
    WIP = wpStatus()
    # print(StoreStatus())
    STStore = StoreStatus()
    FP = STStore[0]
    STA = STStore[1]
    STC = STStore[2]

    TJ_WIP = WIP[0]
    SX_WIP = WIP[1]
    YD_WIP = WIP[2]
    Dye_WIP = WIP[3]
    DX_WIP = WIP[4]
    YB_WIP = WIP[4]
    DJ_WIP = WIP[4]
    # print(SX_WIP)
    # print(TJ_WIP)
    # print(statusVar)
    TJ_eq = statusVar[0]
    MM_eq = statusVar[1]
    Dye_eq1 = statusVar[2]
    # print(Dye_eq1)
    Dye_eq2 = statusVar[3]
    # print(Dye_eq2)
    Dye_eq3 = statusVar[4]
    # print(Dye_eq3)
    Dye_eq4 = statusVar[5]
    # print(Dye_eq4)
    Dye_eq5 = statusVar[6]
    # print(Dye_eq5)
    Dye_eq6 = statusVar[7]
    # print(Dye_eq6)
    PB_eq = statusVar[8]
    DB_eq = statusVar[9]
    TS_eq = statusVar[10]
    FB_eq = statusVar[11]
    SX_eq = statusVar[12]
    DX_eq1 = statusVar[13]
    DX_eq2 = statusVar[14]
    DJ_eq = statusVar[15]
    YB_eq = statusVar[16]

    return render_template('KanBan/FloorPlan.html', TJ_eq = TJ_eq, MM_eq = MM_eq, Dye_eq1 = Dye_eq1, Dye_eq2 = Dye_eq2, Dye_eq3 = Dye_eq3, Dye_eq4 = Dye_eq4, Dye_eq5 = Dye_eq5, Dye_eq6 = Dye_eq6, PB_eq = PB_eq, DB_eq = DB_eq, TS_eq = TS_eq, FB_eq = FB_eq, SX_eq = SX_eq, DX_eq1 = DX_eq1, DX_eq2 = DX_eq2, DJ_eq = DJ_eq, YB_eq = YB_eq, TJ_WIP = TJ_WIP, SX_WIP = SX_WIP, YD_WIP = YD_WIP, Dye_WIP = Dye_WIP, DX_WIP = DX_WIP, YB_WIP = YB_WIP, DJ_WIP = DJ_WIP, FP = FP, STA = STA, STC = STC)


