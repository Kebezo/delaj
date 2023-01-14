from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_login import LoginManager
from flask_migrate import Migrate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///market.db'
#app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://cwlkzhaflhnlqp:1f621c51884cd54cfd4034c913e0e73c2a87370c6d851467a72d6b297a9be387@ec2-107-23-76-12.compute-1.amazonaws.com:5432/d1ndcce7tti1i'
#randomly genereirano hexadecimal stevilo
app.config['SECRET_KEY'] = '52627e432fe1def0e3834e53'
bcrypt = Bcrypt(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager(app)
login_manager.login_view = ('login_page')
login_manager.login_message_category = 'info'

from market import Routes