from market import app
from flask import render_template, redirect, url_for, flash, request, session
from market.Models import Item, User, Zdravnik, Ordinacija, Ponudba, Naslov, Kraj, Termin
from market.Forms import RegisterForm, LoginForm, PurchaseItemForm, SellItemForm, DateForm, OrdinacijaForm
from market import db
from flask_login import login_user, logout_user, login_required, current_user
import folium
from flask_table import Table, Col
from datetime import datetime, timedelta

@app.before_first_request
def create_tables():
    db.create_all()
@app.route("/")
def home():
    ordinacije = []
    for o in Ordinacija.query.all():
        ordinacije.append(o.ime)

    return render_template("base.html", ordinacije=ordinacije)
@app.route('/home')
def home_page():
    return render_template('home.html')

@app.route('/termin', methods=['GET', 'POST'])
@login_required
def market_page():
    select_form = PurchaseItemForm()
    selling_form = SellItemForm()
    datum = DateForm()

    ordinacijaform = OrdinacijaForm()
    if request.method == "POST":
        #Purchase Item Logic
        purchased_item = request.form.get('purchased_item')
        p_item_object = Item.query.filter_by(name=purchased_item).first()



        if p_item_object:
            session['item'] = p_item_object.name


            #if current_user.can_purchase(p_item_object):
               # p_item_object.buy(current_user)
                #flash(f"Congratulations! You purchased {p_item_object.name} for {p_item_object.price}$", category='success')

            #else:
                #flash(f"Unfortunately, you don't have enough money to purchase {p_item_object.name}!", category='danger')
        #Sell Item Logic
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
        flash((d,'T', ura1[0]))
        ponudba = Ponudba.query.filter(Ponudba.id == x[3]).first()
        dolzina = ponudba.dolzina
        time_string = ura1[0]
        time = datetime.strptime(time_string, "%H:%M:%S").time()
        new_time = (datetime.combine(datetime.today(), time) + timedelta(minutes=dolzina*30)).time()
        time_string = new_time.strftime("%H:%M:%S")
        termin = Termin(datum=d,cas=ura1[0],punudba=x[3],uporabnik=current_user.id, koncni_cas = time_string)
        db.session.add(termin)
        db.session.commit()



    if request.method == "GET":
        items = (
            db.session.query(Ordinacija, Zdravnik, Naslov)
                .join(Zdravnik, Ordinacija.lastnik == Zdravnik.id)
                .join(Naslov, Ordinacija.lokacija == Naslov.id)
                .all()
        )

        owned_items = Item.query.filter_by(owner=current_user.id)

        selected_ordinacija = request.args.get('idmogoce')
        flash(selected_ordinacija)
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
        return render_template('termin.html', items=items, purchase_form=select_form, owned_items=owned_items, selling_form=selling_form, datum=datum, termini=termini, ordinacija = ordinacijaform, user=user, appointments=appointments)
    return redirect(url_for('market_page'))
@app.route('/register', methods=['GET', 'POST'])
def register_page():
    form = RegisterForm()
    if form.validate_on_submit():
        user_to_create = User(username=form.username.data,
                              email_address=form.email_address.data,
                              password=form.password1.data,
                              role="pacient")
        db.session.add(user_to_create)
        db.session.commit()

        login_user(user_to_create)
        flash(f'Accunt {user_to_create.username} crearted succesfully', category='success')

        return redirect(url_for('market_page'))
    if form.errors != {}: #If there are not errors from the validations
        for err_msg in form.errors.values():
            flash(f'There was an error with creating a user: {err_msg}', category='danger')

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
            flash(f'Success! You are logged in as: {attempted_user.username}', category='success')
            if attempted_user.role=="pacient":
                return redirect(url_for('market_page'))
            elif attempted_user.role=="zdravnik":
                return  redirect(url_for('zdravnik_page'))
        else:
            flash('Username and password are not match! Please try again', category='danger')

    return render_template('login.html', form=form)

@app.route('/logout')
def logout_page():
    logout_user()
    flash('You are loge out', category='info')
    return redirect(url_for('home_page'))


@app.route("/user")
def user_page():
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
    return render_template("user.html", user=user, appointments=appointments)


@app.route("/cancel_appointment/<int:id>", methods=["POST"])
def cancel_appointment(id):
    appointment = Termin.query.get(id)
    db.session.delete(appointment)
    db.session.commit()
    flash("Sestanek je bil uspešno preklican")
    return redirect(url_for("market_page"))

@app.route('/zdravnik')
def zdravnik_page():
    user = User.query.get(current_user.id)
    current_time = datetime.now()

    appointments = (
        db.session.query(Termin, Ponudba, Ordinacija, Zdravnik)
            .join(Ponudba, Termin.punudba == Ponudba.id)
            .join(Zdravnik, Zdravnik.id == Ordinacija.lastnik)
            .join(Ordinacija, Ordinacija.id == Ponudba.ordinacija)
            .filter(Zdravnik.email == user.email_address)
            .filter(Termin.datum + ' ' + Termin.cas >= current_time)
            .order_by(Termin.datum)
            .all()
    )
    return render_template("zdravnik.html", user=user, appointments=appointments)

@app.route("/confirm_appointment/<int:id>", methods=["POST"])
def confirm_appointment(id):
    appointment = Termin.query.get(id)
    appointment.status = "Sprejet"
    db.session.commit()
    flash("Sestanek je bil uspešno sprejet")
    return redirect(url_for("zdravnik_page"))

@app.route("/zavrni_appointment/<int:id>", methods=["POST"])
def zavrni_appointment(id):
    appointment = Termin.query.get(id)
    appointment.status = "Zavrnjen"
    db.session.commit()
    flash("Sestanek je bil uspešno zavrnjen")
    return redirect(url_for("zdravnik_page"))
