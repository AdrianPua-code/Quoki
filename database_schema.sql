-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS finance_db;
USE finance_db;

-- Tabla para Transacciones (Ingresos, Gastos, Deudas)
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(36) PRIMARY KEY, -- Usaremos UUID generado en la app
    title VARCHAR(255) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    date DATETIME NOT NULL,
    type ENUM('income', 'expense', 'debt') NOT NULL,
    is_paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para Ahorros (Savings)
CREATE TABLE IF NOT EXISTS savings (
    id VARCHAR(36) PRIMARY KEY,
    goal_name VARCHAR(255) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0.00,
    target_amount DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla opcional para Configuración de Usuario (ej. Ingreso Mensual base)
CREATE TABLE IF NOT EXISTS user_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    key_name VARCHAR(50) UNIQUE NOT NULL,
    value VARCHAR(255)
);

-- Insertar valor inicial para el ingreso mensual (ejemplo)
INSERT INTO user_settings (key_name, value) VALUES ('monthly_income', '0.00') ON DUPLICATE KEY UPDATE value = value;
