from flask_script import Manager
from app import app
from gevent import monkey, pywsgi

monkey.patch_all()

if __name__ == "__main__":
    server = pywsgi.WSGIServer(('127.0.0.1', 5000), app)
    server.serve_forever()