CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users (user_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);