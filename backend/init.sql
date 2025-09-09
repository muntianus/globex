-- Placeholder schema for initial Postgres setup
-- Adjust as needed for your application

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(255),
    full_name VARCHAR(255),
    hashed_password TEXT NOT NULL,
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed admin user placeholder (password should be set via app logic)
-- INSERT INTO users (username, email, full_name, hashed_password, disabled)
-- VALUES ('admin', 'admin@example.com', 'Admin User', '<bcrypt-hash-here>', FALSE)
-- ON CONFLICT (username) DO NOTHING;

