# -*-coding:utf-8-*-
from . import home
from flask import render_template, Flask, request

@home.route('/')
def index():
    return render_template('home/base.html')

@home.route('/basedata/')
def basedata():
    return render_template('home/equipment.html')

