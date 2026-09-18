import os

os.environ.setdefault(
    "DATABASE_URL",
    "postgresql+psycopg://barista:barista-dev-password@localhost:5432/barista",
)

from app import app


def test_contact_validation():
    client = app.test_client()

    response = client.post(
        "/api/contact",
        json={
            "name": "",
            "email": "",
            "message": "",
        },
    )

    assert response.status_code == 400


def test_reservation_validation():
    client = app.test_client()

    response = client.post(
        "/api/reservations",
        json={
            "customer_name": "",
            "email": "",
        },
    )

    assert response.status_code == 400


def test_health_endpoint():
    client = app.test_client()

    response = client.get("/api/health")

    assert response.status_code in (200, 503)
