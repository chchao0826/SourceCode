import os
from sqlalchemy import create_engine
import pymssql

SECRET_KEY = os.urandom(24)

# 253配置
HOSTNAME_253 = '198.168.6.253'
PORT_253 = '1433'
DATANAME_253 = 'HSWarpERP_NJYY'
USERNAME_253 = 'fabrictrade'
PASSWORD_253 = 'fabric@2015'

engine_253 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME_253,PASSWORD_253,HOSTNAME_253,PORT_253,DATANAME_253),deprecate_large_types=True) 



HOSTNAME = '198.168.6.236'
PORT = '1433'
DATANAME = 'WebDataBase'
USERNAME = 'sa'
PASSWORD = 'czlingtai2018'

engine_236 = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types=True)


SQLALCHEMY_TRACK_MODIFICATIONS = False





connect = pymssql.connect(HOSTNAME_253, USERNAME_253, PASSWORD_253, DATANAME_253)