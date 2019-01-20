from flask import Flask

app = Flask(__name__)
app.debug = True

# home
from app.home import home as home_blueprint
app.register_blueprint(home_blueprint)

# kanban
from app.kanban import kanban as kanban_blueprint
app.register_blueprint(kanban_blueprint, url_prefix = '/kanban/')

# checkin
from app.checkin import checkin as checkin_blueprint
app.register_blueprint(checkin_blueprint, url_prefix = '/checkin/')

# checkin
from app.expect import expect as expect_blueprint
app.register_blueprint(expect_blueprint, url_prefix = '/expect/')