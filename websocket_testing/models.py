from pydantic import BaseModel, EmailStr
from typing import Optional, List

# Pydantic models
class RegisterRequest(BaseModel):
    name: str
    surname: str
    username: str
    email: EmailStr
    businessName: str
    businessType: str
    password: str
    userType: str

class LoginRequest(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: str
    name: str
    surname: str
    username: str
    email: str
    businessName: str
    businessType: str
    userType: str

class TokenResponse(BaseModel):
    token: str
    user: UserResponse
    message: str

class ItemResponse(BaseModel):
    id: str
    supplier: str
    name: str
    description: str
    price: float
    finalPrice: float
    weight: float
    quantity: int
    category: str
    unit: str
    discountPercent: float
    minimumOrderQuantity: int
    stockLevel: int
    isAvailable: bool
    imageUrl: Optional[str] = None
    createdAt: str

class ItemRequest(BaseModel):
    name: str
    description: str
    price: float
    weight: float
    quantity: int
    category: str
    unit: str
    discountPercent: float = 0.0
    minimumOrderQuantity: int = 1
    stockLevel: int
    isAvailable: bool = True
    imageUrl: Optional[str] = None

class CategoryResponse(BaseModel):
    name: str
    count: int

class OrderRequest(BaseModel):
    user_id: str
    supplier_id: str
    items: List[ItemResponse]
    total_amount: float
    delivery_address: str
    notes: Optional[str] = None
    status: str = "pending"

class OrderResponse(BaseModel):
    id: str
    user_id: str
    supplier_id: str
    items: List[ItemResponse]
    total_amount: float
    delivery_address: str
    notes: Optional[str] = None
    status: str
    created_at: str
    updated_at: str

class ConfirmationResponse(BaseModel):
    status: bool
    message: str

class OrdersResponse(BaseModel):
    orders: list[OrderResponse]
