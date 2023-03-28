from market import db, login_manager
from market import bcrypt
from flask_login import UserMixin
from sqlalchemy.orm import relationship
from flask_migrate import Migrate
import datetime

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

class User(db.Model, UserMixin):
    __tablename__ = 'User'
    id = db.Column(db.Integer(), primary_key=True)
    username = db.Column(db.String(length=30), nullable=False, unique=True)
    email_address = db.Column(db.String(length=60), nullable=False, unique=True)
    password_hash = db.Column(db.String(length=60), nullable=False)
    role = db.Column(db.String)
    kzzs = db.Column(db.Integer, nullable=False)
    items = db.relationship('Item', backref='owned_user', lazy=True)
    termin = db.relationship('Termin', backref='Termin', lazy=True)
    last_login = db.Column(db.Date, default=datetime.datetime.utcnow)

    @property
    def password(self):
        return self.password

    @password.setter
    def password(self, plain_text_password):
        self.password_hash = bcrypt.generate_password_hash(plain_text_password).decode('utf-8')
    def check_password_correction(self, attempted_password):
        return bcrypt.check_password_hash(self.password_hash, attempted_password)



class Item(db.Model):
    __tablename__ = 'Item'
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(length=30), nullable=False, unique=True)
    price = db.Column(db.Integer(), nullable=False)
    barcode = db.Column(db.String(length=12), nullable=False, unique=True)
    description = db.Column(db.String(length=1024), nullable=False, unique=True)
    owner = db.Column(db.Integer(), db.ForeignKey('User.id'))
    def __repr__(self):
        return f'Item {self.name}'

    def buy(self, user):
        self.owner = user.id
        user.budget -= self.price
        db.session.commit()

    def sell(self, user):
        self.owner = None
        user.budget += self.price
        db.session.commit()


class Ordinacija(db.Model):
    __tablename__ = 'Ordinacija'
    id = db.Column(db.Integer(), primary_key=True)
    ime = db.Column(db.String(), nullable=False, unique=True)
    telefon = db.Column(db.String(), nullable=False, unique=True)
    email = db.Column(db.String(), nullable=False, unique=True)
    odpre = db.Column(db.String(), nullable=False)
    zapre = db.Column(db.String(), nullable=False)
    lastnik = db.Column(db.Integer(), db.ForeignKey('Zdravnik.id'))
    TipOrdinacije = db.Column(db.Integer(), db.ForeignKey('TipOrdinacije.id'))
    ponudba = db.relationship('Ponudba', backref='ponudba', lazy=True)
    lokacija = db.Column(db.Integer(), db.ForeignKey('Naslov.id'))
    zdravniki = db.relationship('PomocnikZdravnik', backref='zdravnik_ordinacija', lazy=True)
    rating_sum = db.Column(db.Integer(), default=0)
    num_ratings = db.Column(db.Integer(), default=0)
    average_rating = db.Column(db.Float(), default=0.0)

class TipOrdinacije(db.Model):
    __tablename__ = 'TipOrdinacije'
    id = db.Column(db.Integer(), primary_key=True)
    picture_link = db.Column(db.String(length=200), nullable=False)
    type_name = db.Column(db.String(length=30), nullable=False)
    opis = db.Column(db.String)
    ordinacija = db.relationship('Ordinacija', backref='TipOrdinacije8', lazy=True)

class Zdravnik(db.Model):
    __tablename__ = 'Zdravnik'
    id = db.Column(db.Integer(), primary_key=True)
    ime = db.Column(db.String(), nullable=False, unique=True)
    priimek = db.Column(db.String(), nullable=False, unique=True)
    email = db.Column(db.String(length=60), nullable=False, unique=True)
    password_hash = db.Column(db.String(length=60), nullable=False)
    naziv = db.Column(db.String(), nullable=False)
    ordinacija = db.relationship('Ordinacija', backref='glavni_zdravnik', lazy=True)

class PomocnikZdravnik(db.Model):
    __tablename__ = 'PomocnikZdravnik'
    id = db.Column(db.Integer(), primary_key=True)
    ime = db.Column(db.String(), nullable=False, unique=True)
    priimek = db.Column(db.String(), nullable=False, unique=True)
    email = db.Column(db.String(length=60), nullable=False, unique=True)
    naziv = db.Column(db.String(), nullable=False)
    ponudba = db.relationship('Ponudba', backref='zdravnik_ponudba', lazy=True)
    ordinacija = db.Column(db.Integer(), db.ForeignKey('Ordinacija.id'))

class Termin(db.Model):
    __tablename__ = 'Termin'
    id = db.Column(db.Integer(), primary_key=True, autoincrement=True)
    datum = db.Column(db.String())
    cas = db.Column(db.String())
    koncni_cas = db.Column(db.String())
    status = db.Column(db.String(), default="Nepotrjeno")
    timestamp = db.Column(db.Date(), default=datetime.datetime.utcnow)
    punudba = db.Column(db.Integer(), db.ForeignKey('Ponudba.id'))
    uporabnik = db.Column(db.Integer(), db.ForeignKey('User.id'))
class Ponudba(db.Model):
    __tablename__ = 'Ponudba'
    id = db.Column(db.Integer(), primary_key=True, autoincrement=True)
    naziv = db.Column(db.String(), nullable=False, unique=True)
    dolzina = db.Column(db.Integer())
    opis = db.Column(db.String())
    ordinacija = db.Column(db.Integer(), db.ForeignKey('Ordinacija.id'))
    zdravnik = db.Column(db.Integer(), db.ForeignKey('PomocnikZdravnik.id'))
    termin = db.relationship('Termin', backref='termin', lazy=True)

class Naslov(db.Model):
    __tablename__ = 'Naslov'
    id = db.Column(db.Integer(), primary_key=True, autoincrement=True)
    ulica = db.Column(db.String(), nullable=False)
    naslov = db.Column(db.Integer(), nullable=False)
    ordinacija = db.relationship('Ordinacija', backref='ordinacija', lazy=True)
    kraj = db.Column(db.Integer(), db.ForeignKey('Kraj.id'))

class Kraj(db.Model):
    __tablename__ = 'Kraj'
    id = db.Column(db.Integer(), primary_key=True, autoincrement=True)
    ime = db.Column(db.String(), nullable=False)
    postna = db.Column(db.Integer(), nullable=False)
    naslov = db.relationship('Naslov', backref='Naslov', lazy=True)