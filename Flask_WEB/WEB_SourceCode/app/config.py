import os
from sqlalchemy import create_engine
import pypyodbc


DEBUG = True
SECRET_KEY = os.urandom(24)

HOSTNAME = '198.168.6.236'
PORT = '1433'
DATANAME = 'WebDataBase'
USERNAME = 'sa'
PASSWORD = 'czlingtai2018'

engine_236 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types=True)

# HOSTNAME = '192.168.1.6'
# PORT = '1433'
# DATANAME = 'WebDataBase'
# USERNAME = 'sa'
# PASSWORD = 'gyhb2234'

# engine_236 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types=True)


# 253配置
HOSTNAME_253 = '198.168.6.253'
PORT_253 = '1433'
DATANAME_253 = 'HSWarpERP_NJYY'
USERNAME_253 = 'fabrictrade'
PASSWORD_253 = 'fabric@2015'

engine_253 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME_253,PASSWORD_253,HOSTNAME_253,PORT_253,DATANAME_253),deprecate_large_types=True) 

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

SQLALCHEMY_TRACK_MODIFICATIONS = False