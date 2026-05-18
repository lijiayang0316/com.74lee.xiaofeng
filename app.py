"""
小凤桶装水 - 科技感官网
"""
from flask import Flask, render_template, request, jsonify
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)

@app.route('/')
def index():
    return render_template('index.html')



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9002, debug=False)
