from fastapi import FastAPI, HTTPException, Depends, status, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
from typing import Optional, List
from datetime import datetime, timedelta
import jwt
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import json
import os

from models import *
from configuration import *


# In-memory fake user database
users_db_path = './data/users_db.json'
if os.path.exists(users_db_path):
    with open(users_db_path, 'r') as f:
        fake_users_db = json.load(f)
else:
    fake_users_db = {}

# In-memory fake catalog database
catalog_db_path = './data/catalog_db.csv'
if os.path.exists(catalog_db_path):
    fake_catalog_db = pd.read_csv(catalog_db_path)
    fake_catalog_db['created_at'] = pd.to_datetime(fake_catalog_db['created_at'])
else:
    fake_catalog_db = pd.DataFrame(columns=[
        'id', 'supplier', 'name', 'description',
        'price', 'weight', 'quantity',
        'category', 'unit', 'discount_percent',
        'min_order_qty', 'stock_level', 'is_available',
        'image_url', 'created_at'
    ])

fake_catalog_db = fake_catalog_db.astype({
    'id': str, 'supplier': str, 'name': str, 'description': str,
    'price': float, 'weight': float, 'quantity': int,
    'category': str, 'unit': str, 'discount_percent': float,
    'min_order_qty': int, 'stock_level': int, 'is_available': bool,
    'image_url': str
})
fake_catalog_db['created_at'] = pd.to_datetime(fake_catalog_db['created_at'])

# In-memory fake orders database
orders_db_path = './data/orders_db.json'
if os.path.exists(orders_db_path):
    with open(orders_db_path, 'r') as f:
        fake_orders_db = json.load(f)
else:
    fake_orders_db = {}

# In-memory fake user-supplier link database
fake_link_db_path = './data/link_db.json'
if os.path.exists(fake_link_db_path):
    with open(fake_link_db_path, 'r') as f:
        fake_link_db = json.load(f)
else:
    fake_link_db = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup code
    print("Application starting up...")
    # Create data directory if it doesn't exist
    os.makedirs('./data', exist_ok=True)
    yield
    # Shutdown code
    print("Application shutting down...")
    with open(users_db_path, 'w') as f:
        json.dump(fake_users_db, f, indent=2)
    with open(orders_db_path, 'w') as f:
        json.dump(fake_orders_db, f, indent=2)
    with open(fake_link_db_path, 'w') as f:
        json.dump(fake_link_db, f, indent=2)
    fake_catalog_db.to_csv(catalog_db_path, index=False)
    print("Data saved successfully!")

# Initialize FastAPI app
app = FastAPI(title="Foody App API", lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()


# Helper functions
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=60)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid authentication credentials")
        return user_id
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Could not validate credentials")

def row_to_item_response(row) -> ItemResponse:
    """Convert DataFrame row to ItemResponse"""
    final_price = row['price'] * (1 - row['discount_percent'] / 100)
    return ItemResponse(
        id=str(row['id']),
        supplier=str(row['supplier']),
        name=row['name'],
        description=row['description'],
        price=float(row['price']),
        finalPrice=round(final_price, 2),
        weight=float(row['weight']),
        quantity=int(row['quantity']),
        category=row['category'],
        unit=row['unit'],
        discountPercent=float(row['discount_percent']),
        minimumOrderQuantity=int(row['min_order_qty']),
        stockLevel=int(row['stock_level']),
        isAvailable=bool(row['is_available']),
        imageUrl=row['image_url'] if pd.notna(row['image_url']) else None,
        createdAt=row['created_at'].isoformat() if pd.notna(row['created_at']) else datetime.utcnow().isoformat()
    )


# API Endpoints
@app.post("/api/auth/token/", response_model=TokenResponse, status_code=status.HTTP_200_OK)
async def login(request: LoginRequest):
    """Login endpoint - authenticates user and returns JWT token"""
    user = fake_users_db.get(request.username)

    print(request.username)
    print(fake_users_db.values())

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password"
        )

    if not verify_password(request.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password"
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]},
        expires_delta=access_token_expires
    )

    user_response = UserResponse(
        id=user["id"],
        name=user["name"],
        surname=user["surname"],
        username=user["username"],
        email=user["email"],
        businessName=user["businessName"],
        businessType=user["businessType"],
        userType=user["userType"]
    )

    return TokenResponse(
        token=access_token,
        user=user_response,
        message="Login successful"
    )

@app.post("/api/auth/register/", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(request: RegisterRequest):
    """Register endpoint - creates new user account and returns JWT token"""
    if request.email in fake_users_db:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    if request.username in fake_users_db:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already registered"
            )

    if len(request.password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 6 characters long"
        )

    user_id = f"user_{len(fake_users_db) + 1}"
    hashed_password = hash_password(request.password)

    new_user = {
        "id": user_id,
        "name": request.name,
        "surname": request.surname,
        "username": request.username,
        "email": request.email,
        "businessName": request.businessName,
        "businessType": request.businessType,
        'userType': request.userType,
        "hashed_password": hashed_password,
        "created_at": datetime.utcnow().isoformat()
    }

    fake_users_db[request.username] = new_user
    if request.userType == 'consumer':
        fake_link_db[user_id] = []

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": new_user["id"]},
        expires_delta=access_token_expires
    )

    user_response = UserResponse(
        id=new_user["id"],
        name=new_user["name"],
        surname=new_user["surname"],
        username=new_user["username"],
        email=new_user["email"],
        businessName=new_user["businessName"],
        businessType=new_user["businessType"],
        userType=new_user['userType']
    )

    return TokenResponse(
        token=access_token,
        user=user_response,
        message="Registration successful"
    )

@app.get("/api/items/", response_model=List[ItemResponse])
async def get_items(
    user_id: str, # = Depends(verify_token),
    search: Optional[str] = Query(None, description="Search in name and description"),
    category: Optional[str] = Query(None, description="Filter by category"),
    sort: Optional[str] = Query(None, description="Sort by: name_asc, name_desc, price_asc, price_desc"),
):
    """Get all items with optional filters"""
    global fake_catalog_db

    if fake_catalog_db.empty:
        return []

    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can see items"
        )

    # Create a copy to work with
    filtered_df = fake_catalog_db.copy()

    # Apply consumer-supplier link filter
    # if user_id:
    #     suppliers_ids = fake_link_db.get(user_id, [])
    #     filtered_df = filtered_df[
    #         filtered_df['supplier'].isin(suppliers_ids)
    #     ]
    # else:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN,
    #         detail="Only suppliers can add items"
    #     )

    # Apply search filter
    if search:
        search_lower = search.lower()
        filtered_df = filtered_df[
            filtered_df['name'].str.lower().str.contains(search_lower, na=False) |
            filtered_df['description'].str.lower().str.contains(search_lower, na=False)
        ]

    # Apply category filter
    if category:
        filtered_df = filtered_df[filtered_df['category'] == category]

    # Apply sorting
    if sort:
        if sort == 'name_asc':
            filtered_df = filtered_df.sort_values('name', ascending=True)
        elif sort == 'name_desc':
            filtered_df = filtered_df.sort_values('name', ascending=False)
        elif sort == 'price_asc':
            filtered_df = filtered_df.sort_values('price', ascending=True)
        elif sort == 'price_desc':
            filtered_df = filtered_df.sort_values('price', ascending=False)

    # Convert to list of ItemResponse
    items = [row_to_item_response(row) for _, row in filtered_df.iterrows()]

    return items

@app.post("/api/items/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def add_item(
    request: ItemRequest,
    user_id: str, # = Depends(verify_token)
):
    """Add a new item to catalog (supplier only)"""
    global fake_catalog_db

    # Get user info to check if supplier
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user or user['userType'] != 'supplier':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can add items"
        )

    # Generate new item ID
    item_id = f"item_{len(fake_catalog_db) + 1}" if not fake_catalog_db.empty else "item_1"

    # Create new item
    new_item = {
        'id': item_id,
        'supplier': user['id'],
        'name': request.name,
        'description': request.description,
        'price': request.price,
        'weight': request.weight,
        'quantity': request.quantity,
        'category': request.category,
        'unit': request.unit,
        'discount_percent': request.discountPercent,
        'min_order_qty': request.minimumOrderQuantity,
        'stock_level': request.stockLevel,
        'is_available': request.isAvailable,
        'image_url': request.imageUrl,
        'created_at': datetime.utcnow()
    }

    # Add to DataFrame
    fake_catalog_db = pd.concat([
        fake_catalog_db,
        pd.DataFrame([new_item])
    ], ignore_index=True)

    # Save immediately
    fake_catalog_db.to_csv(catalog_db_path, index=False)

    return ConfirmationResponse(
        status=True,
        message='Item has been added successfuly'
    )

@app.get("/api/categories/{user_id}", response_model=List[CategoryResponse])
async def get_categories(user_id: str): # = Depends(verify_token)):
    """Get all categories with item counts"""
    global fake_catalog_db

    print(user_id)

    if fake_catalog_db.empty:
        return []

    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can add items"
        )

    # Group by category and count
    category_counts = fake_catalog_db.groupby('category').size().reset_index(name='count')

    categories = [
        CategoryResponse(name=row['category'], count=int(row['count']))
        for _, row in category_counts.iterrows()
    ]

    return categories

@app.get("/api/items/{item_id}", response_model=ItemResponse)
async def get_item_by_id(
    item_id: str,
    user_id: str, # = Depends(verify_token)
):
    """Get a specific item by ID"""
    global fake_catalog_db

    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can add items"
        )

    if fake_catalog_db.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    # Find item by ID
    item_row = fake_catalog_db[fake_catalog_db['id'] == item_id]

    if item_row.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with id '{item_id}' not found"
        )

    # Convert to ItemResponse
    return row_to_item_response(item_row.iloc[0])

@app.put("/api/items/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: str,
    request: ItemRequest,
    user_id: str, # = Depends(verify_token)
):
    """Update an existing item (supplier only, own items only)"""
    global fake_catalog_db

    if fake_catalog_db.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user or user['userType'] != 'supplier':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can update items"
        )

    # Find item
    item_idx = fake_catalog_db[fake_catalog_db['id'] == item_id].index

    if item_idx.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with id '{item_id}' not found"
        )

    # Check if user owns this item
    if fake_catalog_db.loc[item_idx[0], 'supplier'] != user['id']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update your own items"
        )

    # Update item
    fake_catalog_db.loc[item_idx[0], 'name'] = request.name
    fake_catalog_db.loc[item_idx[0], 'description'] = request.description
    fake_catalog_db.loc[item_idx[0], 'price'] = request.price
    fake_catalog_db.loc[item_idx[0], 'weight'] = request.weight
    fake_catalog_db.loc[item_idx[0], 'quantity'] = request.quantity
    fake_catalog_db.loc[item_idx[0], 'category'] = request.category
    fake_catalog_db.loc[item_idx[0], 'unit'] = request.unit
    fake_catalog_db.loc[item_idx[0], 'discount_percent'] = request.discountPercent
    fake_catalog_db.loc[item_idx[0], 'min_order_qty'] = request.minimumOrderQuantity
    fake_catalog_db.loc[item_idx[0], 'stock_level'] = request.stockLevel
    fake_catalog_db.loc[item_idx[0], 'is_available'] = request.isAvailable
    fake_catalog_db.loc[item_idx[0], 'image_url'] = request.imageUrl

    # Save immediately
    fake_catalog_db.to_csv(catalog_db_path, index=False)

    return row_to_item_response(fake_catalog_db.loc[item_idx[0]])

@app.delete("/api/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: str,
    user_id: str, # = Depends(verify_token)
):
    """Delete an item (supplier only, own items only)"""
    global fake_catalog_db

    if fake_catalog_db.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )

    # Get user info
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user or user['userType'] != 'supplier':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can delete items"
        )

    # Find item
    item_idx = fake_catalog_db[fake_catalog_db['id'] == item_id].index

    if item_idx.empty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item with id '{item_id}' not found"
        )

    # Check if user owns this item
    if fake_catalog_db.loc[item_idx[0], 'supplier'] != user['id']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own items"
        )

    # Delete item
    fake_catalog_db = fake_catalog_db.drop(item_idx)

    # Save immediately
    fake_catalog_db.to_csv(catalog_db_path, index=False)

    return None

@app.post("/api/orders/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    request: OrderRequest,
    user_id: str, # = Depends(verify_token)
):
    """Create a new order"""
    global fake_orders_db

    # Get user info
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    # Verify user_id matches authenticated user
    if user['id'] != request.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot create order for another user"
        )

    # Verify supplier exists
    supplier_exists = any(
        u['id'] == request.supplier_id and u['userType'] == 'supplier'
        for u in fake_users_db.values()
    )

    if not supplier_exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier not found"
        )

    # Generate order ID
    order_id = f"order_{len(fake_orders_db) + 1}"

    # Enrich items with item names
    enriched_items = []
    for item in request.items:
        item_data = {
            'item_id': item.item_id,
            'quantity': item.quantity,
            'price': item.price
        }

        # Try to get item name from catalog
        if not fake_catalog_db.empty:
            catalog_item = fake_catalog_db[fake_catalog_db['id'] == item.item_id]
            if not catalog_item.empty:
                item_data['item_name'] = catalog_item.iloc[0]['name']

        enriched_items.append(item_data)

    # Create order
    now = datetime.utcnow().isoformat()
    new_order = {
        'id': order_id,
        'user_id': request.user_id,
        'supplier_id': request.supplier_id,
        'items': enriched_items,
        'total_amount': request.total_amount,
        'delivery_address': request.delivery_address,
        'notes': request.notes,
        'status': request.status,
        'created_at': now,
        'updated_at': now
    }

    fake_orders_db[order_id] = new_order

    # Save immediately
    with open(orders_db_path, 'w') as f:
        json.dump(fake_orders_db, f, indent=2)

    return OrderResponse(**new_order)


@app.get("/api/orders/{user_id}", response_model=OrdersResponse)
async def get_user_orders(
    user_id: str, # = Depends(verify_token),
    status_filter: Optional[str] = Query(None, description="Filter by order status")
):
    """Get all orders for a specific user"""
    global fake_orders_db

    # Get user info
    user = None

    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    # Check authorization - users can only see their own orders, suppliers can see orders placed with them
    # if user['userType'] == 'customer' and user['id'] != user_id:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN,
    #         detail="Cannot view orders for another user"
    #     )

    # Filter orders
    user_orders = []
    for order in fake_orders_db.values():
        # For customers: show their orders
        # For suppliers: show orders placed with them
        if user['userType'] == 'consumer':
            if order['user_id'] == user_id:
                if status_filter is None or order['status'] == status_filter:
                    user_orders.append(OrderResponse(**order))
        elif user['userType'] == 'supplier':
            if order['supplier_id'] == user['id']:
                if status_filter is None or order['status'] == status_filter:
                    user_orders.append(OrderResponse(**order))

    # Sort by created_at descending (newest first)
    user_orders.sort(key=lambda x: x.created_at, reverse=True)
    print(user_orders)
    return OrdersResponse(
        orders=user_orders
    )

@app.get("/api/orders/detail/{order_id}", response_model=OrderResponse)
async def get_order_by_id(
    order_id: str,
    user_id: str, # = Depends(verify_token)
):
    """Get a specific order by ID"""
    global fake_orders_db

    # Get user info
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    # Find order
    order = fake_orders_db.get(order_id)

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order with id '{order_id}' not found"
        )

    # Check authorization
    if user['userType'] == 'customer' and order['user_id'] != user['id']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot view another user's order"
        )
    elif user['userType'] == 'supplier' and order['supplier_id'] != user['id']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot view orders from other suppliers"
        )

    return OrderResponse(**order)

@app.patch("/api/orders/{order_id}/", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    status_update: dict,
    user_id: str, # = Depends(verify_token)
):
    """Update order status (cancel order or update status)"""
    global fake_orders_db

    # Get user info
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    # Find order
    order = fake_orders_db.get(order_id)

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order with id '{order_id}' not found"
        )

    new_status = status_update.get('status')

    if not new_status:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status field is required"
        )

    # Authorization rules:
    # - Customers can cancel their own pending orders
    # - Suppliers can update status of orders placed with them
    if user['userType'] == 'customer':
        if order['user_id'] != user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot modify another user's order"
            )
        if new_status != 'cancelled':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Customers can only cancel orders"
            )
        if order['status'] != 'pending':
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Can only cancel pending orders"
            )
    elif user['userType'] == 'supplier':
        if order['supplier_id'] != user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot modify orders from other suppliers"
            )
        # Suppliers can update to: processing, shipped, delivered, cancelled
        valid_statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
        if new_status not in valid_statuses:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
            )

    # Update order
    order['status'] = new_status
    order['updated_at'] = datetime.utcnow().isoformat()

    # Save immediately
    with open(orders_db_path, 'w') as f:
        json.dump(fake_orders_db, f, indent=2)

    return OrderResponse(**order)

@app.get("/api/supplier/orders/", response_model=List[OrderResponse])
async def get_supplier_orders(
    user_id: str, # = Depends(verify_token),
    status_filter: Optional[str] = Query(None, description="Filter by order status")
):
    """Get all orders for the authenticated supplier"""
    global fake_orders_db

    # Get user info
    user = None
    for u in fake_users_db.values():
        if u['id'] == user_id:
            user = u
            break

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )

    if user['userType'] != 'supplier':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only suppliers can access this endpoint"
        )

    # Filter orders for this supplier
    supplier_orders = []
    for order in fake_orders_db.values():
        if order['supplier_id'] == user['id']:
            if status_filter is None or order['status'] == status_filter:
                supplier_orders.append(OrderResponse(**order))

    # Sort by created_at descending (newest first)
    supplier_orders.sort(key=lambda x: x.created_at, reverse=True)

    return supplier_orders

@app.get("/")
async def root():
    return {
        "message": "Foody App API is running",
        "version": "1.0.0",
        "endpoints": {
            "auth": "/api/auth/token/, /api/auth/register/",
            "items": "/api/items/",
            "categories": "/api/categories/",
            "orders": "/api/orders/"
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)