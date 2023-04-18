from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager
from flask_migrate import Migrate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///market.db'
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://famnsunqzhgcyy:55c707ba6311bbdb6c76e957be4858f79dbadeb7795e5bb8e4bbd56a6d7e678d@ec2-3-234-204-26.compute-1.amazonaws.com:5432/d1ubpqjkg8edrs'
#randomly genereirano hexadecimal stevilo
app.config['SECRET_KEY'] = '52627e432fe1def0e3834e53'
bcrypt = Bcrypt(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager(app)
login_manager.login_view = ('login_page')
login_manager.login_message_category = 'info'
account_sid = "ACa72d647b699a5003f642c32b9cd6574b"
auth_token = "e2890d6681670d40b5193903ed885e53"


from market import Routes