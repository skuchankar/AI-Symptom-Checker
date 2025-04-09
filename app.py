from flask import Flask 
app = Flask(__name__)

@app.route("/")
def home():
    return "hello World, from Flask!"

from flask import Flask, render_template, request, redirect, url_for, session, flash
import sqlite3
import pickle
import os
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

# Flask App Setup
app = Flask(__name__)
app.secret_key = "super_secret_key"
DATABASE = 'database/symptom_checker.db'

# Load ML Model
model = pickle.load(open('model/trained_model.pkl', 'rb'))

# ──── DATABASE HELPERS ─────────────────────────
def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# ──── ROUTES ────────────────────────────────────

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        password = generate_password_hash(request.form['password'])
        conn = get_db_connection()
        conn.execute("INSERT INTO User (Name, Email, Password, RegistrationDate, Role, IsVerified) VALUES (?, ?, ?, ?, ?, ?)",
                     (name, email, password, datetime.now(), "Patient", 1))
        conn.commit()
        conn.close()
        flash("Registration successful!", "success")
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        conn = get_db_connection()
        user = conn.execute("SELECT * FROM User WHERE Email = ?", (email,)).fetchone()
        conn.close()
        if user and check_password_hash(user['Password'], password):
            session['user_id'] = user['UserID']
            session['role'] = user['Role']
            flash('Logged in successfully!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid credentials', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash("Logged out successfully.", "info")
    return redirect(url_for('index'))

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    return render_template('dashboard.html', role=session.get('role'))

@app.route('/symptom-check', methods=['GET', 'POST'])
def symptom_check():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        symptoms = request.form.getlist('symptoms')
        input_vector = [1 if sym in symptoms else 0 for sym in model['symptoms']]
        prediction = model['classifier'].predict([input_vector])[0]
        confidence = max(model['classifier'].predict_proba([input_vector])[0]) * 100

        conn = get_db_connection()
        conn.execute("INSERT INTO SymptomCheckResult (UserID, ReportedSymptoms, PredictedCondition, ConfidenceScore, DateChecked, RiskLevel) VALUES (?, ?, ?, ?, ?, ?)",
                     (session['user_id'], ', '.join(symptoms), prediction, round(confidence, 2), datetime.now(), "Moderate"))
        conn.commit()
        conn.close()

        return render_template('symptom_form.html', result=prediction, confidence=round(confidence, 2), symptoms=symptoms)
    
    return render_template('symptom_form.html', symptoms=model['symptoms'])

@app.route('/history')
def history():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    conn = get_db_connection()
    rows = conn.execute("SELECT * FROM SymptomCheckResult WHERE UserID = ? ORDER BY DateChecked DESC", 
                        (session['user_id'],)).fetchall()
    conn.close()
    return render_template('history.html', rows=rows)

@app.route('/feedback', methods=['GET', 'POST'])
def feedback():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    if request.method == 'POST':
        result_id = request.form['result_id']
        text = request.form['feedback_text']
        rating = int(request.form['rating'])
        suggestion_type = request.form['suggestion_type']
        conn = get_db_connection()
        conn.execute("INSERT INTO Feedback (UserID, ResultID, FeedbackText, Rating, SuggestionType, FeedbackDate, Status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                     (session['user_id'], result_id, text, rating, suggestion_type, datetime.now(), 'Pending'))
        conn.commit()
        conn.close()
        flash("Thanks for your feedback!", "success")
        return redirect(url_for('dashboard'))
    conn = get_db_connection()
    results = conn.execute("SELECT * FROM SymptomCheckResult WHERE UserID = ?", 
                           (session['user_id'],)).fetchall()
    conn.close()
    return render_template('feedback.html', results=results)

@app.route('/admin')
def admin_dashboard():
    if session.get('role') != 'Admin':
        return redirect(url_for('dashboard'))
    conn = get_db_connection()
    users = conn.execute("SELECT COUNT(*) FROM User").fetchone()[0]
    results = conn.execute("SELECT COUNT(*) FROM SymptomCheckResult").fetchone()[0]
    feedbacks = conn.execute("SELECT COUNT(*) FROM Feedback WHERE Status = 'Pending'").fetchone()[0]
    conn.close()
    return render_template('admin_dashboard.html', users=users, results=results, feedbacks=feedbacks)

# ──── RUN APP ────────────────────────────────────

if __name__ == '__main__':
    if not os.path.exists('database'):
        os.makedirs('database')
    app.run(debug=True)
