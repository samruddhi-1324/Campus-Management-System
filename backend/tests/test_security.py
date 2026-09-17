from jose import jwt

from app.core.config import settings
from app.core.security import (
    ALGORITHM,
    create_access_token,
    create_refresh_token,
    get_password_hash,
    verify_password,
)
from app.models.user import UserRole


def test_password_hashing():
    pw = "SuperSecret123!"
    hashed = get_password_hash(pw)
    assert hashed != pw
    assert verify_password(pw, hashed) is True
    assert verify_password("WrongPassword", hashed) is False


def test_jwt_access_token_generation():
    user_id = "test-user-uuid"
    role = UserRole.COORDINATOR.value
    token = create_access_token(subject=user_id, role=role, extra_claims={"email": "coord@campus.edu"})

    payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    assert payload["sub"] == user_id
    assert payload["role"] == role
    assert payload["email"] == "coord@campus.edu"
    assert "exp" in payload


def test_jwt_refresh_token_generation():
    user_id = "test-user-uuid"
    token = create_refresh_token(subject=user_id)

    payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    assert payload["sub"] == user_id
    assert payload["type"] == "refresh"
    assert "exp" in payload
