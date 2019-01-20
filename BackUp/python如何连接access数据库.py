import pypyodbc
#定义考勤
def mdb_conn():
    """
    功能：创建数据库连接
    :param db_name: 数据库名称
    :param db_name: 数据库密码，默认为空
    :return: 返回数据库连接
    """
    db_name = 'C:/Users/CHAO/Documents/我的坚果云/att2000.mdb'
    password = ''
    str = 'Driver={Microsoft Access Driver (*.mdb)};PWD' + password + ";DBQ=" + db_name
    conn = pypyodbc.win_connect_mdb(str)

    return conn

# 部门查询
def check_Department():
    conn = mdb_conn()
    cur = conn.cursor()
    sql = "SELECT A.DEPTID, A.DEPTNAME FROM DEPARTMENTS A"
    sel_data = mdb_sel(cur, sql)
    return sel_data