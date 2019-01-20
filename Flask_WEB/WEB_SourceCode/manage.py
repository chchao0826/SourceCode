from flask_script import Manager
from app import app
from gevent import monkey, pywsgi

monkey.patch_all()

if __name__ == "__main__":
    server = pywsgi.WSGIServer(('198.168.6.56', 5000), app)
    server.serve_forever()