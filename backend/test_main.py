
from fastapi.testclient import TestClient
from main import app, get_password_hash, fake_users_db

client = TestClient(app)

def test_read_main():
    response = client.get('/')
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to the B2B Marketplace Backend!"}

def test_register_user():
    # Test successful registration
    response = client.post(
        "/register/",
        json={
            "username": "newuser",
            "email": "newuser@example.com",
            "full_name": "New User",
            "hashed_password": "newpassword"
        },
    )
    assert response.status_code == 200
    assert response.json()["username"] == "newuser"
    assert "hashed_password" not in response.json()

    # Test registration with existing username
    response = client.post(
        "/register/",
        json={
            "username": "newuser",
            "email": "another@example.com",
            "full_name": "Another User",
            "hashed_password": "anotherpassword"
        },
    )
    assert response.status_code == 400
    assert response.json() == {"detail": "Username already registered"}

def test_login_for_access_token():
    # Ensure the testuser exists (from mock_db in main.py)
    # testuser: password

    # Test successful login
    response = client.post(
        "/token",
        data={
            "username": "testuser",
            "password": "password"
        }
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["token_type"] == "bearer"

    # Test invalid password
    response = client.post(
        "/token",
        data={
            "username": "testuser",
            "password": "wrongpassword"
        }
    )
    assert response.status_code == 401
    assert response.json() == {"detail": "Incorrect username or password"}

    # Test non-existent user
    response = client.post(
        "/token",
        data={
            "username": "nonexistent",
            "password": "password"
        }
    )
    assert response.status_code == 401
    assert response.json() == {"detail": "Incorrect username or password"}

def test_read_users_me():
    # First, get a token for testuser
    login_response = client.post(
        "/token",
        data={
            "username": "testuser",
            "password": "password"
        }
    )
    token = login_response.json()["access_token"]

    # Test access with valid token
    response = client.get(
        "/users/me/",
        headers={
            "Authorization": f"Bearer {token}"
        }
    )
    assert response.status_code == 200
    assert response.json()["username"] == "testuser"
    assert response.json()["email"] == "test@example.com"

    # Test access with invalid token
    response = client.get(
        "/users/me/",
        headers={
            "Authorization": "Bearer invalidtoken"
        }
    )
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate credentials"}

    # Test access without token
    response = client.get(
        "/users/me/"
    )
    assert response.status_code == 401
    assert response.json() == {"detail": "Not authenticated"}
