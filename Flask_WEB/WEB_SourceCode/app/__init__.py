from flask import Flask

app = Flask(__name__)
app.debug = True

# KanBan
from app.KanBan import KanBan as KanBan_blueprint
app.register_blueprint(KanBan_blueprint, url_prefix = '/KanBan/')
