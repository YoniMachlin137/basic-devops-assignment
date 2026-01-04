import random
import time
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route("/")
def index():
    return "Hello World"

@app.route("/about")
def about():
    return "<h1 style='color: red'>About!!!</h1>"

@app.route("/info")
def info():
    return jsonify({
        "app": "python-flask-demo",
        "version": "1.0.0",
        "status": "running"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

@app.route("/slow")
def slow():
    delay = random.uniform(0.1, 0.5)
    time.sleep(delay)
    return jsonify({"delay": delay})

@app.route("/error")
def error():
    return jsonify({"error": "Something went wrong"}), 500

@app.route("/random")
def random_status():
    codes = [200, 200, 200, 201, 400, 404, 500]
    code = random.choice(codes)
    return jsonify({"code": code}), code

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
