import logging
import os
import time

from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from prometheus_client import Counter, Histogram, generate_latest

load_dotenv()

app = Flask(__name__)

CORS(
    app,
    resources={
        r"/api/*": {
            "origins": [
                "http://127.0.0.1:8080",
                "http://localhost:8080"
            ]
        }
    }
)

database_url = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://barista:barista-dev-password@localhost:5432/barista",
)

app.config["SQLALCHEMY_DATABASE_URI"] = database_url
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

logger = logging.getLogger("barista-backend")

REQUEST_COUNT = Counter(
    "barista_http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)

REQUEST_LATENCY = Histogram(
    "barista_http_request_duration_seconds",
    "HTTP request latency",
    ["method", "endpoint"],
)


class ContactMessage(db.Model):
    __tablename__ = "contact_messages"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.now(),
        nullable=False,
    )


class Reservation(db.Model):
    __tablename__ = "reservations"

    id = db.Column(db.Integer, primary_key=True)
    customer_name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(30), nullable=False)
    reservation_date = db.Column(db.Date, nullable=False)
    reservation_time = db.Column(db.Time, nullable=False)
    guest_count = db.Column(db.Integer, nullable=False)
    special_request = db.Column(db.Text)
    status = db.Column(
        db.String(30),
        nullable=False,
        default="pending",
    )
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.now(),
        nullable=False,
    )


@app.before_request
def start_timer():
    request.start_time = time.perf_counter()


@app.after_request
def record_metrics(response):
    endpoint = request.endpoint or "unknown"
    elapsed = time.perf_counter() - getattr(
        request,
        "start_time",
        time.perf_counter(),
    )

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=endpoint,
        status=response.status_code,
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=endpoint,
    ).observe(elapsed)

    logger.info(
        "%s %s %s %.4fs",
        request.method,
        request.path,
        response.status_code,
        elapsed,
    )

    return response


@app.get("/api/health")
def health_check():
    try:
        db.session.execute(db.text("SELECT 1"))

        return jsonify(
            {
                "status": "healthy",
                "service": "barista-backend",
                "database": "connected",
            }
        )
    except Exception:
        logger.exception("Database health check failed")

        return jsonify(
            {
                "status": "unhealthy",
                "service": "barista-backend",
                "database": "unavailable",
            }
        ), 503


@app.post("/api/contact")
def submit_contact():
    data = request.get_json(silent=True) or {}

    name = str(data.get("name", "")).strip()
    email = str(data.get("email", "")).strip()
    message = str(data.get("message", "")).strip()

    if not name or not email or not message:
        return jsonify(
            {
                "error": "name, email and message are required"
            }
        ), 400

    contact = ContactMessage(
        name=name,
        email=email,
        message=message,
    )

    try:
        db.session.add(contact)
        db.session.commit()

        logger.info("Contact message saved from %s <%s>", name, email)

        return jsonify(
            {
                "message": "Contact request saved",
                "id": contact.id,
            }
        ), 201

    except Exception:
        db.session.rollback()
        logger.exception("Failed to save contact message")

        return jsonify(
            {
                "error": "Unable to save contact request"
            }
        ), 500


@app.post("/api/reservations")
def submit_reservation():
    data = request.get_json(silent=True) or {}

    required_fields = [
        "customer_name",
        "email",
        "phone",
        "reservation_date",
        "reservation_time",
        "guest_count",
    ]

    missing_fields = [
        field for field in required_fields
        if not data.get(field)
    ]

    if missing_fields:
        return jsonify(
            {
                "error": "Missing required fields",
                "fields": missing_fields,
            }
        ), 400

    try:
        reservation = Reservation(
            customer_name=str(data["customer_name"]).strip(),
            email=str(data["email"]).strip(),
            phone=str(data["phone"]).strip(),
            reservation_date=data["reservation_date"],
            reservation_time=data["reservation_time"],
            guest_count=int(data["guest_count"]),
            special_request=str(
                data.get("special_request", "")
            ).strip(),
        )

        db.session.add(reservation)
        db.session.commit()

        logger.info(
            "Reservation saved for %s on %s at %s",
            reservation.customer_name,
            reservation.reservation_date,
            reservation.reservation_time,
        )

        return jsonify(
            {
                "message": "Reservation request saved",
                "id": reservation.id,
                "status": reservation.status,
            }
        ), 201

    except (ValueError, TypeError):
        db.session.rollback()

        return jsonify(
            {
                "error": "Invalid reservation date, time or guest count"
            }
        ), 400

    except Exception:
        db.session.rollback()
        logger.exception("Failed to save reservation")

        return jsonify(
            {
                "error": "Unable to save reservation request"
            }
        ), 500


@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": "text/plain; version=0.0.4"
    }


with app.app_context():
    db.create_all()


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", "5000")),
        debug=False,
    )
