from market import app
from flask import render_template, redirect, url_for, flash, request, session, jsonify
from market.Models import Item, User, Zdravnik, Ordinacija, Ponudba, Naslov, Kraj, Termin, TipOrdinacije, \
    PomocnikZdravnik
from market.Forms import RegisterForm, LoginForm, PurchaseItemForm, SellItemForm, DateForm, OrdinacijaForm
from market import db
from flask_login import login_user, logout_user, login_required, current_user
import folium
from flask_table import Table, Col
from datetime import datetime, timedelta
import urllib.parse
from functools import wraps
from sqlalchemy import or_
from markupsafe import Markup
import requests
import urllib.parse
import dateutil.parser
import traceback


@app.template_filter()
def with_index(iterable, start=0):
    return enumerate(iterable, start=start)

@app.template_filter()
def datetimeformat(value, format='%d.%m.%Y'):
    if value is None:
        return ''
    datetime_obj = datetime.strptime(value, '%Y-%m-%d')
    return datetime_obj.strftime(format)


@app.before_first_request
def create_tables():
    db.create_all()


import urllib.parse


@app.template_filter()
def to_date(date_string, date_format='%Y-%m-%d'):
    date = datetime.strptime(date_string, date_format).date()
    return date


@app.context_processor
def base_template_context():
    ordinacije = []
    for o in Ordinacija.query.all():
        ordinacije.append(o.ime)
    mesta = []
    for m in Kraj.query.all():
        mesta.append(m.ime)
    return {
        'base_variable': ordinacije,
        'mesta_variable': mesta
    }


@app.route('/get_coordinates')
def get_coordinates():
    ulica = request.args.get('ulica')
    naslov = request.args.get('naslov')
    postna = request.args.get('postna')
    kraj = request.args.get('kraj')
    if ulica and naslov and postna and kraj:
        address = f"{ulica} {naslov}, {postna} {kraj}"
        url = 'https://nominatim.openstreetmap.org/search/' + urllib.parse.quote(address) + '?format=json'

        response = requests.get(url).json()

        if len(response) > 0:
            lat = float(response[0]["lat"])
            lon = float(response[0]["lon"])
            return jsonify({'lat': lat, 'lon': lon})
        else:
            return jsonify({'error': 'No results found for the given address'})
    else:
        return jsonify({'error': 'Invalid address'})


@app.route("/")
@app.route('/home')
def home_page():
    return render_template('home.html')


@app.route('/termin/<string:specialty>/<string:city>', methods=['GET', 'POST'])
@login_required
def market_page(specialty, city):
    select_form = PurchaseItemForm()
    selling_form = SellItemForm()
    datum = DateForm()

    current_time = datetime.now()

    ordinacijaform = OrdinacijaForm()
    if request.method == "POST":
        # Purchase Item Logic
        purchased_item = request.form.get('purchased_item')
        p_item_object = Item.query.filter_by(name=purchased_item).first()

        if p_item_object:
            session['item'] = p_item_object.name

            # if current_user.can_purchase(p_item_object):
            # p_item_object.buy(current_user)
            # flash(f"Congratulations! You purchased {p_item_object.name} for {p_item_object.price}$", category='success')

            # else:
            # flash(f"Unfortunately, you don't have enough money to purchase {p_item_object.name}!", category='danger')
        # Sell Item Logic
        sold_item = request.form.get('sold_item')
        s_item_object = Item.query.filter_by(name=sold_item).first()
        if s_item_object:
            if current_user.can_sell(s_item_object):
                s_item_object.sell(current_user)
                flash(f"Congratulations! You sold {s_item_object.name} back to market!", category='success')
            else:
                flash(f"Something went wrong with selling {s_item_object.name}", category='danger')

    if datum.validate_on_submit():
        datum1 = request.form['datum']
        x = datum1.split('T')
        ura1 = x[1].split('+')
        cas = datetime.strptime(x[0], '%Y-%m-%d')
        d = cas.strftime('%Y-%m-%d')
        # flash((d,'T', ura1[0]))
        ponudba = Ponudba.query.filter(Ponudba.id == x[3]).first()
        dolzina = ponudba.dolzina
        time_string = ura1[0]
        time = datetime.strptime(time_string, "%H:%M:%S").time()
        new_time = (datetime.combine(datetime.today(), time) + timedelta(minutes=dolzina * 30)).time()
        time_string = new_time.strftime("%H:%M:%S")
        appointments = db.session.query(Termin).join(Ponudba).filter(
            Ponudba.ordinacija == ponudba.ordinacija,
            Termin.datum == d,
            Termin.status != 'Zavrnjen'
        ).order_by(Termin.cas).all()
        se_prekriva = False
        for app in appointments:
            app_time = datetime.strptime(app.cas, "%H:%M:%S").time()
            end_time = datetime.strptime(app.koncni_cas, "%H:%M:%S").time()
            if (time < end_time) and (app_time < new_time):
                se_prekriva = True

        if not se_prekriva:
            flash("Uspešno ste rezervirali pregled", category='success')
            termin = Termin(datum=d, cas=ura1[0], punudba=x[3], uporabnik=current_user.id, koncni_cas=time_string)
            db.session.add(termin)
            db.session.commit()
        else:
            flash("Termini se prekrivajo, izberite drugega", category='danger')

    if request.method == "GET":
        if city.lower() != 'v' and specialty.lower() != 'v':
            items = (
                db.session.query(Ordinacija, Zdravnik, Naslov, Kraj, TipOrdinacije)
                    .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
                    .join(Naslov, Ordinacija.lokacija == Naslov.id)
                    .join(Kraj, Naslov.kraj == Kraj.id)
                    .join(TipOrdinacije, Ordinacija.TipOrdinacije == TipOrdinacije.id)
                    .filter(Kraj.ime == city, TipOrdinacije.type_name == specialty)
                    .all()
            )

        elif city.lower() == 'v' and specialty.lower() != 'v':
            items = (
                db.session.query(Ordinacija, Zdravnik, Naslov, Kraj, TipOrdinacije)
                    .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
                    .join(Naslov, Ordinacija.lokacija == Naslov.id)
                    .join(Kraj, Naslov.kraj == Kraj.id)
                    .join(TipOrdinacije, Ordinacija.TipOrdinacije == TipOrdinacije.id)
                    .filter(TipOrdinacije.type_name == specialty)
                    .all()
            )
        elif city.lower() != 'v' and specialty.lower() == 'v':
            items = (
                db.session.query(Ordinacija, Zdravnik, Naslov, Kraj, TipOrdinacije)
                    .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
                    .join(Naslov, Ordinacija.lokacija == Naslov.id)
                    .join(Kraj, Naslov.kraj == Kraj.id)
                    .filter(Naslov.mesto == city)
                    .all()
            )
        else:
            items = (
                db.session.query(Ordinacija, Zdravnik, Naslov, Kraj, TipOrdinacije)
                    .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
                    .join(Naslov, Ordinacija.lokacija == Naslov.id)
                    .join(Kraj, Naslov.kraj == Kraj.id)
                    .all()
            )
        tip = TipOrdinacije.query.filter_by(type_name=specialty).first()
        link = ''
        opis = ''
        if tip:
            link = tip.picture_link
            opis = tip.opis

        ordinacija_count = len(set((item[0].id, item[0].ime) for item in items))
        num_ponudba = 0
        for item in items:
            num_ponudba = num_ponudba + len(item[0].ponudba)
        types = db.session.query(TipOrdinacije.type_name).all()
        owned_items = Item.query.filter_by(owner=current_user.id)

        selected_ordinacija = request.args.get('idmogoce')

        pomocniki_zdravniki = PomocnikZdravnik.query.all()

        termini = (
            db.session.query(Termin, Ponudba, Ordinacija)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .filter(Termin.status != 'Zavrnjen')
                .all()
        )
        user = User.query.get(current_user.id)
        current_time = datetime.now()

        appointments = (
            db.session.query(Termin, Ponudba, Ordinacija)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .filter(Termin.uporabnik == user.id)
                .filter(Termin.datum + ' ' + Termin.cas >= current_time)
                .order_by(Termin.datum)
                .all()
        )

        danes = current_time.date()
        return render_template('termin.html', specialty=specialty,opis=opis, city=city, items=items, purchase_form=select_form,
                               owned_items=owned_items,
                               selling_form=selling_form, datum=datum, termini=termini, ordinacija=ordinacijaform,
                               user=user, appointments=appointments, current_time=current_time, danes=danes, link=link,
                               ordinacija_count=ordinacija_count, num_ponudba=num_ponudba, types=types,
                               pomocniki_zdravniki=pomocniki_zdravniki
                               )
    return redirect(url_for('market_page', city=city, specialty=specialty))


@app.route('/register', methods=['GET', 'POST'])
def register_page():
    form = RegisterForm()
    if form.validate_on_submit():
        existing_zdravnik = Zdravnik.query.filter_by(email=form.email_address.data).first()
        existing_pomocnik = PomocnikZdravnik.query.filter_by(email=form.email_address.data).first()

        if existing_zdravnik:
            user_to_create = User(
                username=form.username.data,
                email_address=form.email_address.data,
                kzzs=form.kzzs.data,
                password=form.password1.data,
                role="zdravnik"
            )
        elif existing_pomocnik:
            user_to_create = User(
                username=form.username.data,
                email_address=form.email_address.data,
                kzzs=form.kzzs.data,
                password=form.password1.data,
                role="pomocnikzdravnik"
            )
        else:
            user_to_create = User(
                username=form.username.data,
                email_address=form.email_address.data,
                kzzs=form.kzzs.data,
                password=form.password1.data,
                role="pacient"
            )

        db.session.add(user_to_create)
        db.session.commit()

        login_user(user_to_create)
        flash(f'Račun {user_to_create.username} je bil ustvarjen uspešno', category='success')

        return redirect(url_for('izberite_ordinacija'))
    if form.errors != {}:  # If there are not errors from the validations
        for err_msg in form.errors.values():
            flash(f'Napaka pri kreiranju uporabnika: {err_msg}', category='danger')

    return render_template('register.html', form=form)


@app.route('/login', methods=['GET', 'POST'])
def login_page():
    form = LoginForm()
    if form.validate_on_submit():

        attempted_user = User.query.filter_by(username=form.username.data).first()
        if attempted_user and attempted_user.check_password_correction(
                attempted_password=form.password.data
        ):
            login_user(attempted_user)
            flash(f'Čestitam! Logirani ste kot: {attempted_user.username}', category='success')
            if attempted_user.role == "pacient":
                from datetime import datetime, timedelta

                # Calculate the start and end dates of the current week
                today = datetime.now().date()
                start_of_week = today - timedelta(days=today.weekday())
                end_of_week = start_of_week + timedelta(days=6)

                # Query the database for upcoming appointments for the current user and week
                upcoming_appointments = (
                    db.session.query(Termin, Ponudba, Ordinacija)
                        .join(Ponudba, Termin.punudba == Ponudba.id)
                        .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                        .filter(
                        Termin.uporabnik == attempted_user.id,
                        Termin.datum >= today,
                        Termin.datum <= end_of_week
                    ).all()
                )

                # Check if there are any upcoming appointments and display a message
                last_login = attempted_user.last_login
                changes = db.session.query(Termin, Ponudba). \
                    join(Ponudba). \
                    filter(Termin.timestamp >= last_login, Ponudba.ordinacija == attempted_user.id). \
                    all()

                change_messages = "Od vaše zadnje prijave so se spremenili statusi naslednjim terminom: <br>"

                for change in changes:
                    if change.Termin.status != "Nepotrjeno":
                        timestamp = change.Termin.timestamp
                        status = change.Termin.status
                        change_messages += f"{change.Ponudba.naziv}: status spremenjen na {status}<br>"

                if change_messages != "Od vaše zadnje prijave so se spremenili statusi naslednjim terminom: <br>":
                    flash(Markup(change_messages), "info")
                current_user.last_login = datetime.now()
                db.session.commit()

                return redirect(url_for('izberite_ordinacija'))
            elif attempted_user.role == "zdravnik" or  attempted_user.role =='pomocnikzdravnik':
                return redirect(url_for('zdravnik_page'))
            elif attempted_user.role == "admin":
                return redirect(url_for('admin_page'))
        else:
            flash('Uporabniško ime in geslo se ne ujemata, poskusite znova', category='danger')

    return render_template('login.html', form=form)


@app.route('/logout')
def logout_page():
    logout_user()
    flash('Uspešno ste se odjavili', category='info')
    return redirect(url_for('home_page'))


def zdravnik_required(func):
    @wraps(func)
    def decorated_view(*args, **kwargs):
        if not current_user.is_authenticated or current_user.role != "zdravnik" and current_user.role != "pomocnikzdravnik":
            # Redirect to a login page or a forbidden page
            return redirect(url_for('home_page'))
        return func(*args, **kwargs)

    return decorated_view


def admin_required(func):
    @wraps(func)
    def decorated_view(*args, **kwargs):
        if not current_user.is_authenticated or current_user.role != "admin":
            # Redirect to a login page or a forbidden page
            return redirect(url_for('home_page'))
        return func(*args, **kwargs)

    return decorated_view


from flask import request


@app.route("/user", methods=['GET', 'POST'])
def user_page():
    user = User.query.get(current_user.id)
    current_time = datetime.now()
    appointments = (
        db.session.query(Termin, Ponudba, Ordinacija, Kraj, Naslov, Zdravnik)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .join(Naslov, Naslov.id == Ordinacija.lokacija)
            .join(Kraj, Kraj.id == Naslov.kraj)
            .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
            .filter(Termin.uporabnik == user.id)
            .filter(Termin.datum + ' ' + Termin.cas >= current_time)
            .order_by(Termin.datum)
            .all()
    )
    past_appointments = (
        db.session.query(Termin, Ponudba, Ordinacija, Kraj, Naslov, Zdravnik)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .join(Naslov, Naslov.id == Ordinacija.lokacija)
            .join(Kraj, Kraj.id == Naslov.kraj)
            .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
            .filter(Termin.uporabnik == user.id)
            .filter(Termin.status == 'Končano')
            .filter(Termin.datum + ' ' + Termin.cas <= current_time)
            .order_by(Termin.datum)
            .all()
    )

    today = datetime.today()
    start_of_week = today - timedelta(days=today.weekday())
    end_of_week = start_of_week + timedelta(days=6)

    # Filter the appointments to only include those within the current week
    appointments_this_week = [(termin, ponudba, ordinacija, kraj, naslov, zdravnik) for
                              termin, ponudba, ordinacija, kraj, naslov, zdravnik in appointments if
                              today <= datetime.strptime(termin.datum, '%Y-%m-%d') <= end_of_week]

    # Display the appointments for the current week
    if appointments_this_week:
        message = "V tem tednu imate naslednje termine:"
        for appointment in appointments_this_week:
            appointment_date = datetime.strptime(appointment[0].datum, '%Y-%m-%d')
            european_date = appointment_date.strftime('%d.%m.%Y')
            message += f"\n{european_date}: {appointment[1].naziv}"
        flash(message, category='info')
    else:
        flash("V tem tednu nimate nobenih terminov.", category='info')
    today = today.date()
    return render_template("user.html", user=user, appointments=appointments, today=today, past_appointments=past_appointments)


@app.route('/admin')
@login_required
@admin_required
def admin_page():
    user = User.query.get(current_user.id)
    owner_ids = [ordinacija.lastnik for ordinacija in Ordinacija.query.filter_by(lastnik=Zdravnik.id).all()]
    types = db.session.query(TipOrdinacije).all()
    zdravniki = Zdravnik.query.filter(~Zdravnik.id.in_(owner_ids)).all()
    naslovi = Kraj.query.all()
    return render_template("admin.html", user=user, zdravniki=zdravniki, types=types, naslovi=naslovi)


@app.route('/add_ordinacija', methods=['POST'])
def add_ordinacija():
    ime = request.form['ime']
    email = request.form['email']
    addr = request.form['Naslov']
    Ulica = request.form['Ulica']
    lokacija = request.form['lokacija']
    telefon = request.form['telefon']
    odpre = request.form['odpre'] + ':00:00'
    zapre =  request.form['zapre'] + ':00:00'
    lastnik = request.form['lastnik']
    tip = request.form['tip']
    print(tip)
    naslov = Naslov.query.filter_by(kraj=lokacija, ulica=Ulica, naslov=addr).first()
    if naslov is not None:
        naslov_id = naslov.id
    else:
        new_naslov = Naslov(ulica=Ulica, naslov=addr, kraj=lokacija)
        db.session.add(new_naslov)
        db.session.commit()
        naslov_id = new_naslov.id

    new_ordinacija = Ordinacija(
        ime=ime,
        email=email,
        telefon=telefon,
        odpre=odpre,
        zapre=zapre,
        lastnik=lastnik,
        TipOrdinacije=tip,
        lokacija=naslov_id
    )
    db.session.add(new_ordinacija)
    db.session.commit()

    flash('Nova ordinacija uspešno dodana.', 'success')
    return redirect(url_for('admin_page'))


@app.route('/add_glavni_zdravnik', methods=['POST'])
def add_glavni_zdravnik():
    ime = request.form.get('ime')
    priimek = request.form.get('priimek')
    email = request.form.get('email')
    geslo = 'geslo'
    naziv = request.form.get('naziv')
    new_glavni_zdravnik = Zdravnik(ime=ime, priimek=priimek, email=email, password_hash=geslo, naziv=naziv)
    db.session.add(new_glavni_zdravnik)
    db.session.commit()
    flash('Zdravnik je dodan', 'success')
    return redirect(url_for('admin_page'))


@app.route('/add_zdravnik/<int:id>', methods=['POST'])
def add_zdravnik(id):
    ime = request.form.get('ime')
    priimek = request.form.get('priimek')
    email = request.form.get('email')
    telefon = request.form.get('telefon')
    naziv = request.form.get('naziv')
    new_glavni_zdravnik = PomocnikZdravnik(ime=ime, priimek=priimek, email=email, naziv=naziv, ordinacija=id)
    db.session.add(new_glavni_zdravnik)
    db.session.commit()
    flash('Zdravnik je dodan', 'success')
    return redirect(url_for('zdravnik_page'))


@app.route("/cancel_appointment/<int:id>", methods=["POST"])
def cancel_appointment(id):
    appointment = Termin.query.get(id)
    db.session.delete(appointment)
    db.session.commit()
    flash("Sestanek je bil uspešno preklican", 'success')
    if request.form.get('ordinacija'):
        ime = Ordinacija.query.get(request.form.get('ordinacija'))
        return redirect(url_for("show_ordinacija", ordinacija=ime.ime))
    else:
        return redirect(url_for("user_page"))


@app.route('/zdravnik')
@login_required
@zdravnik_required
def zdravnik_page():
    user = User.query.get(current_user.id)
    current_time = datetime.now()
    if current_user.role == "zdravnik":
        appointments = (
            db.session.query(Termin, Ponudba, Ordinacija, Zdravnik, User)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .join(User, User.id == Termin.uporabnik)
                .filter(Zdravnik.email == user.email_address)
                .filter(Termin.datum + ' ' + Termin.cas >= current_time)
                .order_by(Termin.datum)
                .order_by(Termin.cas)
                .all()
        )
        past_appointments = (
            db.session.query(Termin, Ponudba, Ordinacija, Zdravnik, User)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .join(User, User.id == Termin.uporabnik)
                .filter(Zdravnik.email == user.email_address)
                .filter(Termin.datum + ' ' + Termin.cas <= current_time)
                .order_by(Termin.datum)
                .order_by(Termin.cas)
                .all()
        )
        ordinacija_id = Ordinacija.query.join(Zdravnik).filter(Zdravnik.email == user.email_address).first().id
        ponudbe = Ponudba.query.filter_by(ordinacija=ordinacija_id).all()

    elif current_user.role == "pomocnikzdravnik":

        ponudbe = (
            Ponudba.query
                .join(PomocnikZdravnik, PomocnikZdravnik.id == Ponudba.zdravnik)
                .filter(PomocnikZdravnik.email == current_user.email_address)
                .all()
        )

        appointments = (
            db.session.query(Termin, Ponudba, Ordinacija, Zdravnik, User)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .join(User, User.id == Termin.uporabnik)
                .join(PomocnikZdravnik, (PomocnikZdravnik.ordinacija == Ordinacija.id) & (
                    PomocnikZdravnik.email == current_user.email_address))
                .filter(Termin.datum + ' ' + Termin.cas >= current_time)
                .filter(Ponudba.zdravnik == PomocnikZdravnik.id)
                .order_by(Termin.datum)
                .order_by(Termin.cas)
                .all()
        )
        past_appointments = (
            db.session.query(Termin, Ponudba, Ordinacija, Zdravnik, User)
                .join(Ponudba, Termin.punudba == Ponudba.id)
                .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
                .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
                .join(User, User.id == Termin.uporabnik)
                .join(PomocnikZdravnik, (PomocnikZdravnik.ordinacija == Ordinacija.id) & (
                    PomocnikZdravnik.email == current_user.email_address))
                .filter(Termin.datum + ' ' + Termin.cas <= current_time)
                .filter(Ponudba.zdravnik == PomocnikZdravnik.id)
                .order_by(Termin.datum)
                .order_by(Termin.cas)
                .all()
        )


        ordinacija_id = PomocnikZdravnik.query.filter_by(email=current_user.email_address).first().ordinacija

    ordinacija = Ordinacija.query.get(ordinacija_id)
    odpre = [ordinacija.odpre, ordinacija.zapre]
    ordinacija_ime = ordinacija.ime
    pomocniki_zdravniki = PomocnikZdravnik.query.filter_by(ordinacija=ordinacija_id).all()


    return render_template("zdravnik.html", user=user, appointments=appointments, past_appointments=past_appointments,
                       ordinacija_id=ordinacija_id, ponudbe=ponudbe, ordinacija_ime=ordinacija_ime,
                       pomocniki_zdravniki=pomocniki_zdravniki, odpre=odpre)


@app.route("/confirm_appointment/<int:id>", methods=["POST"])
def confirm_appointment(id):
    appointment = Termin.query.get(id)
    appointment.status = "Sprejet"
    now = datetime.now()
    date_only = now.date()
    appointment.timestamp = date_only  # set the timestamp to the current datetime
    db.session.commit()
    flash("Sestanek je bil uspešno sprejet", "success")
    return redirect(url_for("zdravnik_page"))


@app.route("/zavrni_appointment/<int:id>", methods=["POST"])
def zavrni_appointment(id):
    appointment = Termin.query.get(id)
    appointment.status = "Zavrnjen"
    now = datetime.now()
    date_only = now.date()
    appointment.timestamp = date_only  # s
    db.session.commit()
    flash("Sestanek je bil uspešno zavrnjen", "success")
    return redirect(url_for("zdravnik_page"))


@app.route("/finish_appointment/<int:id>", methods=["POST"])
def finish_appointment(id):
    appointment = Termin.query.get(id)
    appointment.status = "Končano"
    now = datetime.now()
    date_only = now.date()
    appointment.timestamp = date_only  # s
    db.session.commit()
    flash("Sestanek je bil uspešno končan", "success")
    return redirect(url_for("zdravnik_page"))


@app.route('/ordinacija/<string:ordinacija>')
@login_required
def show_ordinacija(ordinacija):
    ordinacija1 = (
        db.session.query(Ordinacija, Zdravnik, Naslov, Kraj)
            .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
            .join(Naslov, Ordinacija.lokacija == Naslov.id)
            .join(Kraj, Naslov.kraj == Kraj.id)
            .filter(Ordinacija.ime == ordinacija)
            .first()
    )
    current_time = datetime.now()
    user = User.query.get(current_user.id)
    appointments = (
        db.session.query(Termin, Ponudba, Ordinacija)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .filter(Termin.uporabnik == user.id)
            .filter(Ordinacija.ime == ordinacija)
            .filter(Termin.datum + ' ' + Termin.cas >= current_time)
            .order_by(Termin.datum)
            .all()
    )
    past_appointments = (
        db.session.query(Termin, Ponudba, Ordinacija)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .filter(Termin.uporabnik == user.id)
            .filter(Ordinacija.ime == ordinacija)
            .filter(Termin.datum + ' ' + Termin.cas < current_time)
            .order_by(Termin.datum)
            .all()
    )
    print(ordinacija1, "asdasdasdasdasdasdasdasdasd")
    naslov = ordinacija1.Naslov.naslov
    postna = ordinacija1.Kraj.postna
    kraj = ordinacija1.Kraj.ime
    ulica = ordinacija1.Naslov.ulica
    address = f"{ulica} {naslov}, {postna} {kraj}"
    url = 'https://nominatim.openstreetmap.org/search/' + urllib.parse.quote(address) + '?format=json'

    response = requests.get(url).json()
    lat = (response[0]["lat"])
    lon = (response[0]["lon"])
    return render_template('ordinacija.html', ordinacija=ordinacija1, appointments=appointments,
                           past_appointments=past_appointments, lat=lat, lon=lon)


@app.route('/izberite_ordinacija/', methods=['GET', 'POST'])
@login_required
def izberite_ordinacija():
    items = (
        db.session.query(Ordinacija, Zdravnik, Naslov, Kraj)
            .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
            .join(Naslov, Ordinacija.lokacija == Naslov.id)
            .join(Kraj, Naslov.kraj == Kraj.id)
            .all()
    )
    types = db.session.query(TipOrdinacije.type_name).all()

    return render_template('izberite_ordinacija.html', items=items, types=types)


@app.route("/rate_ordinacija/<int:ordinacija_id>/<int:termin_id>", methods=["POST"])
@login_required
def rate_ordinacija(ordinacija_id, termin_id):
    rating = int(request.form["rating"])
    ordinacija = Ordinacija.query.get(ordinacija_id)
    rating_sum = ordinacija.rating_sum + rating
    num_ratings = ordinacija.num_ratings + 1
    average_rating = rating_sum / num_ratings
    ordinacija.rating_sum = rating_sum
    ordinacija.num_ratings = num_ratings
    ordinacija.average_rating = average_rating

    termin = Termin.query.get(termin_id)
    termin.status = ("Ocenjeno")

    db.session.commit()
    flash("Uspešno ste ocenili ordinacijo", category="success")
    if request.form.get('from_user_page'):
        return redirect(url_for("user_page"))
    else:
        return redirect(url_for("show_ordinacija", ordinacija=ordinacija.ime))



@app.route('/add_ponudba/<int:id>', methods=['GET', 'POST'])
@login_required
def add_ponudba(id):
    if request.method == 'POST':
        naziv = request.form['naziv']
        dolzina = request.form['dolzina']
        opis = request.form['opis']
        lastnik = request.form['lastnik']
        dolzina = int(dolzina) / 30
        ponudba = Ponudba(naziv=naziv, dolzina=dolzina, ordinacija=id, opis=opis, zdravnik=lastnik)
        db.session.add(ponudba)
        db.session.commit()
        flash('Uspešno ste dodali ponudbo.', 'success')
        return redirect(url_for('zdravnik_page'))
    return render_template('zdravnik.html')


@app.route('/delete_ponudba', methods=['POST'])
@login_required
def delete_ponudba():
    ponudba_id = request.form.get('ponudba_id')
    ponudba = Ponudba.query.get(ponudba_id)
    if ponudba:
        db.session.delete(ponudba)
        db.session.commit()
        flash('Uspešno ste izbrisali ponudbo.', 'success')
    else:
        flash('Ponudba ne obstaja.', 'error')
    return redirect(url_for('zdravnik_page'))


def is_date_free(ponudba_id, ordinacija_id, date, duration, working_hours_start, working_hours_end):
    appointments = (
        db.session.query(Termin, Ponudba, Ordinacija)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .filter(Termin.datum == date, Ordinacija.id == ordinacija_id)
            .filter(Termin.status!='Zavrnjen')
            .all()
    )
    if not appointments:
        return True

    interval = timedelta(minutes=duration)

    current_time = datetime.combine(date, working_hours_start)
    end_time = datetime.combine(date, working_hours_end)

    while current_time < end_time:
        start_time = current_time
        e = start_time + interval
        is_available = True
        for app in appointments:
            app_time = datetime.strptime(app.Termin.cas, "%H:%M:%S").time()
            app_end_time = datetime.strptime(app.Termin.koncni_cas, "%H:%M:%S").time()
            app_time = datetime.combine(date, app_time)
            app_end_time = datetime.combine(date, app_end_time)
            if (start_time < app_end_time) and (app_time < e):
                is_available = False
                break  # break out of the loop as soon as we find an unavailable slot

        if is_available:
            return True

        current_time += interval

    return False


@app.route('/get_free_slots', methods=['GET'])
def get_free_slots():
    ponudba_id = int(request.args.get('ponudba_id'))
    ordinacija_id = int(request.args.get('ordinacija_id'))
    date = datetime.strptime(request.args.get('date'), '%Y-%m-%d').date()
    duration = int(request.args.get('duration')) * 30;
    working_hours_start = datetime.strptime(request.args.get('working_hours_start'), '%H:%M:%S').time()
    working_hours_end = datetime.strptime(request.args.get('working_hours_end'), '%H:%M:%S').time()

    dates = [datetime.now().date() + timedelta(days=i) for i in range(100)]
    availability = {}
    for date in dates:
        availability[str(date)] = is_date_free(ponudba_id, ordinacija_id, date, duration, working_hours_start,
                                               working_hours_end)
    return availability


@login_required
@app.route('/update_user_data', methods=['POST'])
def update_user_data():
    if request.method == 'POST':
        attempted_user = User.query.filter_by(username=current_user.username).first()
        if attempted_user and attempted_user.check_password_correction(
                attempted_password=request.form['password']
        ):
            new_username = request.form['username']
            new_email_address = request.form['email_address']
            new_kzzs = request.form['kzzs']

            # Check if the new username or email already exist in the database
            existing_user = User.query.filter(
                or_(User.username == new_username, User.email_address == new_email_address)).first()
            if existing_user and existing_user.id != current_user.id:
                flash('Uporabniško ime ali e-mail že obstajajo.', 'danger')
                return redirect(url_for('user_page'))

            # Update the user object with the new values
            current_user.username = new_username
            current_user.email_address = new_email_address
            current_user.kzzs = new_kzzs
            db.session.commit()

            flash('Uspešno ste posodobili vaše podatke.', 'success')
            return redirect(url_for('user_page'))
        else:
            flash("Vnesli ste napačno geslo", 'danger')

    return render_template('user.html', user=current_user)


@app.route('/change_password', methods=['POST'])
@login_required
def change_password():
    current_password = request.form['current_password']
    new_password = request.form['new_password']
    confirm_password = request.form['confirm_password']

    if current_user.check_password_correction(current_password):
        if new_password == confirm_password:
            current_user.password = (new_password)
            db.session.commit()
            flash('Uspešno ste spremenili geslo!', 'success')
            return redirect(url_for('user_page'))
        else:
            flash('Gesli se ne ujemata!', 'danger')
    else:
        flash('Vnesli ste napačno geslo!', 'danger')

    return redirect(url_for('user_page'))


@app.route('/edit_ponudba<int:id>', methods=['POST'])
@login_required
def edit_ponudba(id):
    ponudba = Ponudba.query.filter_by(id=id).first()
    ponudba.naziv = request.form['naziv']
    ponudba.dolzina = request.form['dolzina']
    ponudba.opis = request.form['opis']
    if 'lastnik' in request.form:
        ponudba.zdravnik = request.form['lastnik']
    db.session.commit()

    flash('Ponudba je bila uspešno posodobljena.', 'success')
    return redirect(url_for('zdravnik_page'))

