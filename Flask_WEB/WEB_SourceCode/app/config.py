import os
from sqlalchemy import create_engine
import pymssql

DEBUG = True
SECRET_KEY = os.urandom(24)

# HOSTNAME = '192.168.1.5'
# PORT = '1433'
# DATANAME = 'YYLT'
# USERNAME = 'sa'
# PASSWORD = 'gyhb2234'

HOSTNAME = '198.168.6.236'
PORT = '1433'
DATANAME = 'WebDataBase'
USERNAME = 'sa'
PASSWORD = 'czlingtai2018'

engine = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types=True)


connect = pymssql.connect(HOSTNAME, USERNAME, PASSWORD, DATANAME)