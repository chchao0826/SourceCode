import os
from sqlalchemy import create_engine

DEBUG = True

SECRET_KEY = os.urandom(24)

HOSTNAME = '198.168.6.56'
PORT = '1433'
DATANAME = 'YYLT'
USERNAME = 'sa'
PASSWORD = '123!!'

engine = create_engine("mssql+pymssql://{}:{}@{}:{}/{}?charset=utf8".format(USERNAME,PASSWORD,HOSTNAME,PORT,DATANAME),deprecate_large_types = True)

SQLALCHEMY_TRACK_MODIFICATIONS = False