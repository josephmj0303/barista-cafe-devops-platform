import os
import sys
import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from app import app


@pytest.fixture()
def client():
    app.config.update(TESTING=True)

    with app.app_context():
        from app import db
        db.drop_all()
        db.create_all()

    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    response = client.get("/api/health")

    assert response.status_code == 200

    data = response.get_json()

    assert data["status"] == "healthy"
