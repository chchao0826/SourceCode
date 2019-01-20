## kanban
- 基础资料维护/pbCommonDataEquipment
    - id/id
    - 机台号/sEquipmentNo
    - 机台名/sEquipmentName
    - 是否可用/bUsable
    - 小工段/sWorkingProcedureName
    - 大工段/sWorkingProcedureNameBig

- orgatex
    - id
    - sCardNo
    - sColorNo
    - sMaterialNo
    - sCustomerName
    - nFactInputQty
    - tStartTime
    - tPlanEndTime
    - sNowStatus
    - iEquipmentID //对应pbCommonDataEquipment.id

## 考勤
- 人员表/ pbCommonDataEmployee
    - id
    - sEmployeeNo
    - sEmployeeName
    - sStatus
    - tLeaveTime
    - ipbCommonDataDepartmentID //对应pbCommonDataDepartment.id
- 部门信息/ pbCommonDataDepartment
    - id
    - sDeptNo
    - sDeptName
- 考勤录入
    - id
    - tCheckTime
    - ipbCommonDataEm

部门增加是否为长白班