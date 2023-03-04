from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import Length, EqualTo, Email, DataRequired, ValidationError
from market.Models import User


class RegisterForm(FlaskForm):

    def validate_username(self, username_to_check):
        user = User.query.filter_by(username=username_to_check.data).first()
        if user:
            raise ValidationError('Username already exists')

    def validate_kzzs(self, kzzs_to_check):
        kzzs = User.query.filter_by(kzzs=kzzs_to_check.data).first()
        if kzzs_to_check:
            raise ValidationError('Kzzs already exists')
    def validate_email_address(self, email_address_to_check):
        email_address = User.query.filter_by(email_address=email_address_to_check.data).first()
        if email_address:
            raise ValidationError('Email Address already exists')

    username = StringField(label='Uporabniško ime:', validators=[Length(min=2, max=30), DataRequired()])
    email_address = StringField(label='E-mail:', validators=[Email(), DataRequired()])
    kzzs = StringField(label='Kzzs števlika:', validators=[Length(min=9, max=9), DataRequired()])
    password1 = PasswordField(label='Geslo:', validators=[Length(min=6), DataRequired()])
    password2 = PasswordField(label='Ponovite geslo:', validators=[EqualTo('password1'), DataRequired()])
    submit = SubmitField(label='Ustvarite račun:')


class LoginForm(FlaskForm):
    username = StringField(label='Uporabniško ime:', validators=[DataRequired()])
    password = PasswordField(label='Geslo:', validators=[DataRequired()])
    submit = SubmitField(label='Login:')

class PurchaseItemForm(FlaskForm):
    submit = SubmitField(label='Izberite Termin')

class SellItemForm(FlaskForm):
    submit = SubmitField(label='Uredite termin')

class DateForm(FlaskForm):
    submit = SubmitField(label='Izberite datum')

class OrdinacijaForm(FlaskForm):
    submit = SubmitField(label='Izberite ordinacijo')

