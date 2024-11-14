CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders (order_id),
    product_id INT REFERENCES products (product_id),
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);