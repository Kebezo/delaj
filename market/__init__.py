from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///market.db'
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres://qwolcamhdlxiyk:18f14a174f5910629e9a5b31a27ebfc7225f6e6e3956d110512061d22393324b@ec2-3-93-206-109.compute-1.amazonaws.com:5432/db1crkutmj8i5a'
#randomly genereirano hexadecimal stevilo
app.config['SECRET_KEY'] = '52627e432fe1def0e3834e53'
bcrypt = Bcrypt(app)
db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = ('login_page')
login_manager.login_message_category = 'info'

from market import Routes