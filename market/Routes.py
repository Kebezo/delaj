from market import app
from flask import render_template, redirect, url_for, flash, request, session
from market.Models import Item, User, Zdravnik, Ordinacija
from market.Forms import RegisterForm, LoginForm, PurchaseItemForm, SellItemForm, DateForm
from market import db
from flask_login import login_user, logout_user, login_required, current_user
import folium


@app.route('/')
@app.route('/home')
def home_page():
    return render_template('home.html')

@app.route('/termin', methods=['GET', 'POST'])
@login_required
def market_page():
    select_form = PurchaseItemForm()
    selling_form = SellItemForm()
    datum = DateForm()

    if request.method == "POST":
        #Purchase Item Logic
        purchased_item = request.form.get('purchased_item')
        p_item_object = Item.query.filter_by(name=purchased_item).first()

        date = request.form.get('datum_form')

        if p_item_object:
            session['item'] = p_item_object.name


            #if current_user.can_purchase(p_item_object):
               # p_item_object.buy(current_user)
                #flash(f"Congratulations! You purchased {p_item_object.name} for {p_item_object.price}$", category='success')

            #else:
                #flash(f"Unfortunately, you don't have enough money to purchase {p_item_object.name}!", category='danger')
        #Sell Item Logic
        if date:
            session['date'] = date
            flash(date)
        sold_item = request.form.get('sold_item')
        s_item_object = Item.query.filter_by(name=sold_item).first()
        if s_item_object:
            if current_user.can_sell(s_item_object):
                s_item_object.sell(current_user)
                flash(f"Congratulations! You sold {s_item_object.name} back to market!", category='success')
            else:
                flash(f"Something went wrong with selling {s_item_object.name}", category='danger')




    if request.method == "GET":
        items = Zdravnik.query.join(Ordinacija).all()
        owned_items = Item.query.filter_by(owner=current_user.id)

        return render_template('termin.html', items=items, purchase_form=select_form, owned_items=owned_items, selling_form=selling_form, datum = datum)
    return redirect(url_for('market_page'))
@app.route('/register', methods=['GET', 'POST'])
def register_page():
    form = RegisterForm()
    if form.validate_on_submit():
        user_to_create = User(username=form.username.data,
                              email_address=form.email_address.data,
                              password=form.password1.data)
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
            return redirect(url_for('market_page'))
        else:
            flash('Username and password are not match! Please try again', category='danger')

    return render_template('login.html', form=form)

@app.route('/logout')
def logout_page():
    logout_user()
    flash('You are loge out', category='info')
    return redirect(url_for('home_page'))


@app.route('/map')
def map_page():
    #m = folium.Map(location=[45.5236, -122.6750])
    return render_template('map.html')

@app.route('/calendar')
def calendar_page():
    my_var = session.get('item', None)
    flash(my_var)
    #m = folium.Map(location=[45.5236, -122.6750])
    return render_template('calendar.html')
