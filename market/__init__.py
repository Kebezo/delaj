from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager

app = Flask(__name__)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///market.db'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres://qszufkbkhbrbfr:809d522b23bad496eccc9e86d31c7e251308eb32663cc3bf9c7b4e564ae0bedd@ec2-34-199-68-114.compute-1.amazonaws.com:5432/d5bb8o015bpf4i'
#randomly genereirano hexadecimal stevilo
app.config['SECRET_KEY'] = '52627e432fe1def0e3834e53'
bcrypt = Bcrypt(app)
db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = ('login_page')
login_manager.login_message_category = 'info'

from market import Routes