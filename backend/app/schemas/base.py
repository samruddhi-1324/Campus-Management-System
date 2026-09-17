from typing import Any, Generic, TypeVar

from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class CoreModel(BaseModel):
    """Base Pydantic model with default configuration."""
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
        str_strip_whitespace=True,
    )


class ApiResponse(CoreModel, Generic[T]):
    """Standardized envelope for all API responses."""
    success: bool = True
    message: str | None = None
    data: T | None = None
    errors: list[Any] | None = None
