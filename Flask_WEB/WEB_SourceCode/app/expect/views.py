# -*-coding:utf-8-*-
from . import expect
from flask import render_template, Flask, request
from app.SQL.dyeingexpect import dyeingData, pageData, equipmentNo, updateEquipment
from app.SQL.kanban import equipmentList
import json

@expect.route('/')
def index():
    return render_template('expect/base.html')

# 搜索栏搜索数值
@expect.route('/dyeing/<searchValue>')
def dyeing(searchValue):
    pageDataVar = pageData(1, searchValue)
    ReturnValue = pageDataVar[0]
    pageMax = int(pageDataVar[1])
    # 机台增加
    equipmentList = equipmentNo('C', 'D')

    print(searchValue)
    return render_template('expect/dyeing.html', ReturnValue = ReturnValue, pageMax = pageMax, equipmentList = equipmentList)

# 分页地址栏
@expect.route('/dyeing/page/<returnValue>')
def skipPage(returnValue):
    table_data = ''

    returnValue_var = ''.join(returnValue)
    returnValue_list = returnValue_var.split('_')
    pageNum = returnValue_list[1]
    searchvalue = returnValue_list[0]

    ReturnValue = pageData(pageNum, searchvalue)[0]

    # 编辑信息的增加
    table_header = '<table class="table table-striped"><tbody id = "pageMain">\
        <tr>\
            <th hidden = true>ID</th>\
            <th>机台号</th>\
            <th>工卡号</th>\
            <th>物料编号</th>\
            <th>色号</th>\
            <th>重量</th>\
            <th>预排时间</th>\
            <th>上工段完成时间</th>\
            <th>编辑</th>\
        </tr>'
    for var in ReturnValue:
        table_data += '<tr>\
            <td hidden = true> %s </td>\
            <td> <a href="" id="sEquipmentNo-%s" class="editEquipment">%s</a>  </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> <button id="save-%s" onclick="saveBtn("save-%s")">保存</button>  </td>\
        </tr>' %(var["id"], var["id"], var["sEquipmentNo"], var["sCardNo"], var["sMaterialNo"], var["sColorNo"], var["nFactInputQty"], var["tExpectTime"], var["tFactEndTime"], var["id"], var["id"]) 
    table_footer = "</tbody></table>"

    return table_header + table_data + table_footer 

# 保存
@expect.route('/dyeing/save' ,methods=['GET', 'POST'])
def saveBtn():
    if request.method == 'POST':
        getData = json.loads(request.get_data('dataArr'))
        updateEquipment(getData)
    table_header =''
    return table_header


# 搜索使用AJAX,发现以目前的方式不可以实现,转分页AJAX,搜索一般
'''
# AJAX搜索
@expect.route('/dyeing/<searchvalue>')
def search(searchvalue):
    table_data = ''
    ReturnValue = pageData(1, searchvalue)[0]
    # print(ReturnValue)
    # 机台选项卡
    # eq_list = equipmentList()
    # eq_option = ''
    # for var in eq_list:
    #     eq_option += '<option value = %s> %s</option>'

    # 编辑信息的增加
    table_header = '<table class="table table-striped"><tbody id = "pageMain">\
        <tr>\
            <th>ID</th>\
            <th>机台号</th>\
            <th>工卡号</th>\
            <th>物料编号</th>\
            <th>色号</th>\
            <th>重量</th>\
            <th>预排时间</th>\
            <th>上工段完成时间</th>\
            <th>编辑</th>\
        </tr>'
    for var in ReturnValue:
        table_data += '<tr>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> %s </td>\
            <td> <button>编辑</button> </td>\
        </tr>' %(var["id"], var["sEquipmentNo"], var["sCardNo"], var["sMaterialNo"], var["sColorNo"], var["nFactInputQty"], var["tExpectTime"], var["tFactEndTime"]) 
    table_footer = "</tbody></table>"

    # page_sum = int(pageData(1, searchvalue)[1])

    # # 页码的增加
    # nav_title = '<nav aria-label="Page navigation">\
    #                 <ul class="pagination">\
    #                     <li>\
    #                     <a href="#" aria-label="Previous" id="prev">\
    #                         <span aria-hidden="true">&laquo;</span>\
    #                     </a>\
    #                     </li>'
    # nav_data = ''
    
    # # 页码数量
    # for var in range(page_sum):
    #     nav_data += '<li name = "page" id = "page%s"><a href="#">%s</a></li>' %(var,var+1)
    
    # # 页脚
    # nav_footer = '<li>\
    #                 <a href="#" aria-label="Next" id="next">\
    #                     <span aria-hidden="true">&raquo;</span>\
    #                 </a>\
    #                 </li>\
    #             </ul>\
    #         </nav>'

    return table_header + table_data + table_footer 

'''