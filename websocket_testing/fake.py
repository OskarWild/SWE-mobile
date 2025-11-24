import pandas as pd
from datetime import datetime
import json

fake_catalog_db = pd.DataFrame([
    # user_2 items (Supplier 1) - Fresh Produce & Dairy
    {
        'id': 'prod_001',
        'supplier': 'user_2',
        'name': 'Organic Apples',
        'description': 'Fresh organic red apples from local farms. Crisp and sweet.',
        'price': 1200.0,
        'weight': 1.0,
        'quantity': 150,
        'category': 'Fruits',
        'unit': 'kg',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 150,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_002',
        'supplier': 'user_2',
        'name': 'Fresh Tomatoes',
        'description': 'Ripe, juicy tomatoes perfect for salads and cooking.',
        'price': 800.0,
        'weight': 1.0,
        'quantity': 200,
        'category': 'Vegetables',
        'unit': 'kg',
        'discount_percent': 10,
        'min_order_qty': 1,
        'stock_level': 200,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1546470427-e26264be0b0d',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_003',
        'supplier': 'user_2',
        'name': 'Whole Milk',
        'description': 'Fresh whole milk, 3.2% fat. Delivered daily from local dairy farms.',
        'price': 450.0,
        'weight': 1.0,
        'quantity': 100,
        'category': 'Dairy',
        'unit': 'l',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 100,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1563636619-e9143da7973b',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_004',
        'supplier': 'user_2',
        'name': 'Greek Yogurt',
        'description': 'Creamy Greek yogurt with high protein content. Natural and unsweetened.',
        'price': 650.0,
        'weight': 500.0,
        'quantity': 80,
        'category': 'Dairy',
        'unit': 'g',
        'discount_percent': 5,
        'min_order_qty': 1,
        'stock_level': 80,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1488477181946-6428a0291777',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_005',
        'supplier': 'user_2',
        'name': 'Fresh Carrots',
        'description': 'Organic carrots, rich in vitamins and perfect for healthy meals.',
        'price': 500.0,
        'weight': 1.0,
        'quantity': 120,
        'category': 'Vegetables',
        'unit': 'kg',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 120,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_006',
        'supplier': 'user_2',
        'name': 'Bananas',
        'description': 'Sweet yellow bananas, great source of potassium and energy.',
        'price': 600.0,
        'weight': 1.0,
        'quantity': 180,
        'category': 'Fruits',
        'unit': 'kg',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 180,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_007',
        'supplier': 'user_2',
        'name': 'Cheddar Cheese',
        'description': 'Aged cheddar cheese with rich, sharp flavor. Perfect for sandwiches.',
        'price': 2500.0,
        'weight': 500.0,
        'quantity': 50,
        'category': 'Dairy',
        'unit': 'g',
        'discount_percent': 15,
        'min_order_qty': 1,
        'stock_level': 50,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_008',
        'supplier': 'user_2',
        'name': 'Fresh Spinach',
        'description': 'Tender baby spinach leaves, washed and ready to eat.',
        'price': 900.0,
        'weight': 500.0,
        'quantity': 70,
        'category': 'Vegetables',
        'unit': 'g',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 70,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_009',
        'supplier': 'user_2',
        'name': 'Strawberries',
        'description': 'Fresh, sweet strawberries. Perfect for desserts and smoothies.',
        'price': 1800.0,
        'weight': 500.0,
        'quantity': 60,
        'category': 'Fruits',
        'unit': 'g',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 60,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_010',
        'supplier': 'user_2',
        'name': 'Farm Eggs',
        'description': 'Fresh free-range eggs from local farms. Pack of 10 pieces.',
        'price': 800.0,
        'weight': 600.0,
        'quantity': 90,
        'category': 'Dairy',
        'unit': 'pack',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 90,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f',
        'created_at': datetime.now()
    },

    # user_4 items (Supplier 2) - Bakery & Beverages
    {
        'id': 'prod_011',
        'supplier': 'user_4',
        'name': 'Sourdough Bread',
        'description': 'Artisan sourdough bread, freshly baked daily with traditional methods.',
        'price': 1200.0,
        'weight': 700.0,
        'quantity': 40,
        'category': 'Bakery',
        'unit': 'piece',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 40,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_012',
        'supplier': 'user_4',
        'name': 'Croissants',
        'description': 'Buttery, flaky French croissants. Pack of 4 pieces.',
        'price': 1500.0,
        'weight': 300.0,
        'quantity': 50,
        'category': 'Bakery',
        'unit': 'pack',
        'discount_percent': 10,
        'min_order_qty': 1,
        'stock_level': 50,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_013',
        'supplier': 'user_4',
        'name': 'Orange Juice',
        'description': 'Freshly squeezed orange juice, 100% natural with no added sugar.',
        'price': 800.0,
        'weight': 1.0,
        'quantity': 80,
        'category': 'Beverages',
        'unit': 'l',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 80,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_014',
        'supplier': 'user_4',
        'name': 'Chocolate Chip Cookies',
        'description': 'Homemade chocolate chip cookies. Pack of 12 pieces.',
        'price': 1000.0,
        'weight': 400.0,
        'quantity': 60,
        'category': 'Bakery',
        'unit': 'pack',
        'discount_percent': 5,
        'min_order_qty': 1,
        'stock_level': 60,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_015',
        'supplier': 'user_4',
        'name': 'Green Tea',
        'description': 'Premium organic green tea. Box of 25 tea bags.',
        'price': 1800.0,
        'weight': 50.0,
        'quantity': 100,
        'category': 'Beverages',
        'unit': 'box',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 100,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_016',
        'supplier': 'user_4',
        'name': 'Whole Wheat Bread',
        'description': 'Healthy whole wheat bread, high in fiber and nutrients.',
        'price': 900.0,
        'weight': 500.0,
        'quantity': 45,
        'category': 'Bakery',
        'unit': 'piece',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 45,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_017',
        'supplier': 'user_4',
        'name': 'Apple Juice',
        'description': 'Pure apple juice made from fresh apples. No preservatives.',
        'price': 750.0,
        'weight': 1.0,
        'quantity': 70,
        'category': 'Beverages',
        'unit': 'l',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 70,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_018',
        'supplier': 'user_4',
        'name': 'Blueberry Muffins',
        'description': 'Soft and moist blueberry muffins. Pack of 6 pieces.',
        'price': 1300.0,
        'weight': 400.0,
        'quantity': 40,
        'category': 'Bakery',
        'unit': 'pack',
        'discount_percent': 15,
        'min_order_qty': 1,
        'stock_level': 40,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_019',
        'supplier': 'user_4',
        'name': 'Sparkling Water',
        'description': 'Refreshing sparkling mineral water. Pack of 6 bottles.',
        'price': 1400.0,
        'weight': 3.0,
        'quantity': 90,
        'category': 'Beverages',
        'unit': 'pack',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 90,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1523362628745-0c100150b504',
        'created_at': datetime.now()
    },
    {
        'id': 'prod_020',
        'supplier': 'user_4',
        'name': 'Bagels',
        'description': 'Fresh bagels in assorted flavors. Pack of 6 pieces.',
        'price': 1100.0,
        'weight': 450.0,
        'quantity': 55,
        'category': 'Bakery',
        'unit': 'pack',
        'discount_percent': 0,
        'min_order_qty': 1,
        'stock_level': 55,
        'is_available': True,
        'image_url': 'https://images.unsplash.com/photo-1551106652-a5bcf4b29ab6',
        'created_at': datetime.now()
    }
])

# Display summary
fake_catalog_db.to_csv('./data/catalog_db.csv', index=False)

from datetime import datetime, timedelta
import random

# Initialize fake_orders_db if not exists
fake_orders_db = {}

# Helper function to create order
def create_simulated_order(order_id, user_id, supplier_id, items_data, delivery_address, notes, status, days_ago=0):
    created_at = datetime.now() - timedelta(days=days_ago)

    enriched_items = []
    total_amount = 0

    for item_id, quantity in items_data:
        # Get item from catalog
        catalog_item = fake_catalog_db[fake_catalog_db['id'] == item_id].iloc[0]

        # Calculate price with discount
        base_price = catalog_item['price']
        discount = catalog_item['discount_percent']
        final_price = base_price - (base_price * discount / 100)
        item_total = final_price * quantity

        # TODO: make items more items in order insertion
        item_data = catalog_item.to_dict()
        item_data['created_at'] = item_data['created_at'].strftime("%Y-%m-%d %H:%M:%S")
        enriched_items.append(item_data)
        total_amount += item_total

    new_order = {
        'id': order_id,
        'user_id': user_id,
        'supplier_id': supplier_id,
        'items': enriched_items,
        'total_amount': round(total_amount, 2),
        'delivery_address': delivery_address,
        'notes': notes,
        'status': status,
        'created_at': created_at.strftime("%Y-%m-%d %H:%M:%S"),
        'updated_at': created_at.strftime("%Y-%m-%d %H:%M:%S") if status == 'pending' else (created_at + timedelta(hours=random.randint(1, 48))).strftime("%Y-%m-%d %H:%M:%S")
    }

    fake_orders_db[order_id] = new_order
    return new_order

# Orders from user_1 to user_2 (Fresh Produce & Dairy)
create_simulated_order(
    order_id='order_001',
    user_id='user_1',
    supplier_id='user_2',
    items_data=[
        ('prod_001', 2),  # Organic Apples - 2 kg
        ('prod_003', 3),  # Whole Milk - 3 l
        ('prod_009', 1),  # Strawberries - 1 pack
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='Please deliver in the morning',
    status='delivered',
    days_ago=5
)

create_simulated_order(
    order_id='order_002',
    user_id='user_1',
    supplier_id='user_2',
    items_data=[
        ('prod_002', 1),  # Fresh Tomatoes - 1 kg
        ('prod_005', 2),  # Fresh Carrots - 2 kg
        ('prod_008', 1),  # Fresh Spinach - 1 pack
        ('prod_010', 2),  # Farm Eggs - 2 packs
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='',
    status='shipped',
    days_ago=1
)

create_simulated_order(
    order_id='order_003',
    user_id='user_1',
    supplier_id='user_2',
    items_data=[
        ('prod_004', 3),  # Greek Yogurt - 3 packs
        ('prod_007', 2),  # Cheddar Cheese - 2 packs
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='Call before delivery',
    status='processing',
    days_ago=0
)

# Orders from user_1 to user_4 (Bakery & Beverages)
create_simulated_order(
    order_id='order_004',
    user_id='user_1',
    supplier_id='user_4',
    items_data=[
        ('prod_011', 2),  # Sourdough Bread - 2 pieces
        ('prod_012', 1),  # Croissants - 1 pack
        ('prod_013', 2),  # Orange Juice - 2 l
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='Please ensure bread is fresh',
    status='delivered',
    days_ago=7
)

create_simulated_order(
    order_id='order_005',
    user_id='user_1',
    supplier_id='user_4',
    items_data=[
        ('prod_015', 2),  # Green Tea - 2 boxes
        ('prod_019', 1),  # Sparkling Water - 1 pack
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='',
    status='confirmed',
    days_ago=0
)

# Orders from user_3 to user_2 (Fresh Produce & Dairy)
create_simulated_order(
    order_id='order_006',
    user_id='user_3',
    supplier_id='user_2',
    items_data=[
        ('prod_001', 5),  # Organic Apples - 5 kg
        ('prod_006', 3),  # Bananas - 3 kg
        ('prod_009', 2),  # Strawberries - 2 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Large order for family gathering',
    status='delivered',
    days_ago=10
)

create_simulated_order(
    order_id='order_007',
    user_id='user_3',
    supplier_id='user_2',
    items_data=[
        ('prod_002', 3),  # Fresh Tomatoes - 3 kg
        ('prod_005', 2),  # Fresh Carrots - 2 kg
        ('prod_008', 2),  # Fresh Spinach - 2 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Need for salad preparation',
    status='delivered',
    days_ago=3
)

create_simulated_order(
    order_id='order_008',
    user_id='user_3',
    supplier_id='user_2',
    items_data=[
        ('prod_003', 5),  # Whole Milk - 5 l
        ('prod_004', 4),  # Greek Yogurt - 4 packs
        ('prod_010', 3),  # Farm Eggs - 3 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Weekly dairy order',
    status='shipped',
    days_ago=1
)

create_simulated_order(
    order_id='order_009',
    user_id='user_3',
    supplier_id='user_2',
    items_data=[
        ('prod_007', 1),  # Cheddar Cheese - 1 pack
        ('prod_006', 2),  # Bananas - 2 kg
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='',
    status='pending',
    days_ago=0
)

# Orders from user_3 to user_4 (Bakery & Beverages)
create_simulated_order(
    order_id='order_010',
    user_id='user_3',
    supplier_id='user_4',
    items_data=[
        ('prod_011', 3),  # Sourdough Bread - 3 pieces
        ('prod_016', 2),  # Whole Wheat Bread - 2 pieces
        ('prod_020', 2),  # Bagels - 2 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Need fresh bread for the week',
    status='delivered',
    days_ago=4
)

create_simulated_order(
    order_id='order_011',
    user_id='user_3',
    supplier_id='user_4',
    items_data=[
        ('prod_012', 2),  # Croissants - 2 packs
        ('prod_014', 1),  # Chocolate Chip Cookies - 1 pack
        ('prod_018', 2),  # Blueberry Muffins - 2 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='For morning breakfast',
    status='processing',
    days_ago=0
)

create_simulated_order(
    order_id='order_012',
    user_id='user_3',
    supplier_id='user_4',
    items_data=[
        ('prod_013', 3),  # Orange Juice - 3 l
        ('prod_017', 2),  # Apple Juice - 2 l
        ('prod_019', 2),  # Sparkling Water - 2 packs
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Beverage stock for home',
    status='confirmed',
    days_ago=0
)

create_simulated_order(
    order_id='order_013',
    user_id='user_3',
    supplier_id='user_4',
    items_data=[
        ('prod_015', 3),  # Green Tea - 3 boxes
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='Love this tea!',
    status='delivered',
    days_ago=14
)

# Additional mixed orders
create_simulated_order(
    order_id='order_014',
    user_id='user_1',
    supplier_id='user_2',
    items_data=[
        ('prod_006', 2),  # Bananas - 2 kg
        ('prod_010', 1),  # Farm Eggs - 1 pack
    ],
    delivery_address='Kabanbay Batyr Ave 53, Astana, Kazakhstan',
    notes='Quick restock',
    status='cancelled',
    days_ago=2
)

create_simulated_order(
    order_id='order_015',
    user_id='user_3',
    supplier_id='user_4',
    items_data=[
        ('prod_011', 1),  # Sourdough Bread - 1 piece
        ('prod_013', 1),  # Orange Juice - 1 l
    ],
    delivery_address='Mangilik El Ave 55/20, Astana, Kazakhstan',
    notes='',
    status='pending',
    days_ago=0
)

with open("./data/orders_db.json", "w") as f:
    json.dump(fake_orders_db, f, indent=2)
