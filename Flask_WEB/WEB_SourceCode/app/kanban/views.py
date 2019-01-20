# -*-coding:utf-8-*-
from . import kanban
from flask import render_template, Flask, request
from app.SQL.kanban import equipmentList, orgatexList
from app.SQL.PMkanban import PMkanban, PMEquipment, cardCount
from app.SQL.KanBanArea import FactoryFloorPlan, WIPSearch, WIPSet, WIPPre
from app.SQL.equipment import equipmentList, equipmentWP, equipmentUpdate, equipmentGroupList
from app.SQL.store import FPStoreSUM
from app.SQL.dyeKanBan import getSimple, getAbnor

import json

# 主页
@kanban.route('/')
def index():
    return render_template('kanban/base.html')


# orgatex 读取机台区域
@kanban.route('/orgatex/<equipmentNo>')
def orgatex(equipmentNo):
    equipment_List = equipmentGroupList(equipmentNo)
    orgatex_List = orgatexList(equipmentNo)
    return render_template('kanban/orgatex.html', KanBan_Equipment_var=equipment_List, KanBan_Card_var_1=orgatex_List[0], KanBan_Card_var_2=orgatex_List[1])


# 生管看板
@kanban.route('/PM/')
def PMKanBan():
    PMEquipment_var = PMEquipment()
    PMkanban_TJ = PMkanban('配检布', '退卷')
    PMkanban_ZL = PMkanban('水洗预定')
    PMkanban_HY = PMkanban('化验室')
    PMkanban_Dye = PMkanban('染色')
    PM_TJ_Card = PMkanban_TJ[0]
    PM_TJ_Number = PMkanban_TJ[1]
    PM_ZL_Card = PMkanban_ZL[0]
    PM_ZL_Number = PMkanban_ZL[1]
    PM_HY_Card = PMkanban_HY[0]
    PM_HY_Number = PMkanban_HY[1]
    PM_Dye_Card = PMkanban_Dye[0]
    PM_Dye_Number = PMkanban_Dye[1]

    cardCount_var = cardCount('配检布', '退卷', '水洗预定', '化验室', '染色')
    return render_template('kanban/PMkanban.html', PMEquipment_var=PMEquipment_var, PMkanban_TJ=PM_TJ_Card, PMkanban_ZL=PM_ZL_Card, PMkanban_HY=PM_HY_Card, PMkanban_Dye=PM_Dye_Card, PM_TJ_Number=PM_TJ_Number, PM_ZL_Number=PM_ZL_Number, PM_HY_Number=PM_HY_Number, PM_Dye_Number=PM_Dye_Number, cardCount_var=cardCount_var)


# 生管机台
@kanban.route('/PM/sEquipmentNo/<sEquipmentNo>')
def PMEqKanBan(sEquipmentNo):
    return render_template('kanban/PMkanban_Eq.html')


# 工厂平面图
@kanban.route('/FactoryFloorPlan')
def FloorPlan():
    TJ_eq = FactoryFloorPlan('LDR03', 'LDR02', 'LDR01')
    Dye_eq1 = FactoryFloorPlan('E027', 'E030', 'E029')
    Dye_eq2 = FactoryFloorPlan('E028', 'E031', 'E026', 'E025')
    Dye_eq3 = FactoryFloorPlan('A001', 'A002', 'A003', 'A004', 'A005', 'A006', 'C020')
    Dye_eq4 = FactoryFloorPlan('B007', 'B008', 'B009', 'B010')
    Dye_eq5 = FactoryFloorPlan('C015', 'C016', 'C017', 'C018', 'C019')
    Dye_eq6 = FactoryFloorPlan('D021', 'D022', 'D023', 'D024')
    TS_eq = FactoryFloorPlan('LT03', 'LT02', 'LT01')
    SX_eq = FactoryFloorPlan('LS02', 'LS01')
    DX_eq1 = FactoryFloorPlan('LB05', 'LB04')
    DX_eq2 = FactoryFloorPlan('LB03')
    DX_eq3 = FactoryFloorPlan('LB02', 'LB01')
    DJ_eq = FactoryFloorPlan('KJ04', 'KJ03', 'KJ02', 'KJ01')
    YB_eq = FactoryFloorPlan('KI04', 'KI03', 'KI02', 'KI01')
    MM_eq = FactoryFloorPlan('HQ03')
    PB_eq = FactoryFloorPlan('HP01')
    DB_eq = FactoryFloorPlan('订边机')
    FB_eq = FactoryFloorPlan('DR03')
    print('*****'*13)
    print(FPStoreSUM())
    return render_template('kanban/FactoryFloorPlan.html', TJ_eq = TJ_eq, Dye_eq1 = Dye_eq1, Dye_eq2 = Dye_eq2, Dye_eq3 = Dye_eq3, Dye_eq4 = Dye_eq4, Dye_eq5 = Dye_eq5, Dye_eq6 = Dye_eq6, TS_eq = TS_eq, SX_eq = SX_eq, DX_eq1 = DX_eq1,DX_eq2 = DX_eq2,DX_eq3 = DX_eq3, DJ_eq = DJ_eq, YB_eq = YB_eq, MM_eq = MM_eq, PB_eq = PB_eq, DB_eq = DB_eq, FB_eq = FB_eq, WIPPre = WIPPre())


# AJAX 调用工段的机台信息 不可编辑版
@kanban.route('/config/<var_work>')
def Equipment(var_work):

    Equipment_list = equipmentList(var_work)
    table_header = '<table class="table table-hover table-striped"><tbody>\
    <tr>\
        <th>工段列表</th><th>机台编号</th><th>机台名称</th><th>是否可用</th><th>看板顺序</th>\
    </tr>'
    table_data = ''
    for var in Equipment_list:
        table_data += '<tr>\
                            <td name = "sWorkingProcedureName">%s</td> \
                            <td>%s</td> \
                            <td>%s</td> \
                            <td>%s</td> \
                            <td>%s</td> \
                        </tr>'\
            % (var['sWorkingProcedureName'], var['sEquipmentNo'], var['sEquipmentName'], var['bUsable'], var['nRowNumber'])
    table_footer = '</tbody></table>'
    return table_header + table_data + table_footer


# AJAX 调用工段的机台信息 可编辑版
@kanban.route('/config/edit/<var_work>')
def EquipmentEdit(var_work):
    Equipment_list = equipmentList(var_work)
    table_header = '<table class="table table-hover table-striped"><tbody>\
    <tr>\
        <th>工段列表</th><th>机台编号</th><th>机台名称</th><th>是否可用</th><th>看板顺序</th>\
    </tr>'
    table_data = ''
    for var in Equipment_list:
        table_data += '<tr name = "table-tr">\
                            <td name = "sWorkingProcedureName">%s</td> \
                            <td name = "sEquipmentNo"> %s </td> \
                            <td name = "sEquipmentName"> %s </td> \
                            <td><input name = "bUsable" type="checkbox" %s> </td> \
                            <td><input name = "nRowNumber" type="text" value = %s> </td> \
                        </tr>'\
        % (var['sWorkingProcedureName'], var['sEquipmentNo'], var['sEquipmentName'], var['bUsable'], var['nRowNumber'])
    table_footer = '</tbody></table>'
    return table_header + table_data + table_footer

# 机台信息保存事件
@kanban.route('/save/config' ,methods=['GET', 'POST'])
def equipmentSave():
    if request.method == 'POST':
        data_var = json.loads(request.get_data('data'))
        equipmentUpdate(data_var)

    return render_template('kanban/FactoryFloorPlan.html')


# 工段查询
@kanban.route('/config')
def configEquipment():
    equipmentWPList = equipmentWP()
    return render_template('kanban/equipmentConfig.html', equipmentWPList=equipmentWPList)


# 工段WIP
@kanban.route('/WIPconfig' ,methods=['GET', 'POST'])
def WIPconfig():
    if request.method == 'POST':
        data_var = json.loads(request.get_data('data'))
        WIPSet(data_var)
    WIPSearchVar = WIPSearch()

    return render_template('kanban/workceiling.html' ,WIPSearchVar = WIPSearchVar)


# 染色取样看板
@kanban.route('/getSample')
def dyeGetSample():
    getSimple()
    getAbnor()
    return render_template('kanban/dyeingGetSample.html')