CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    specialization TEXT CHECK(specialization IN ('male', 'female', 'universal')) NOT NULL,
    commission_percent REAL NOT NULL CHECK(commission_percent > 0 AND commission_percent <= 100),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    dismissal_date DATE NULL,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE services (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK(duration_minutes > 0),
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    gender TEXT CHECK(gender IN ('male', 'female', 'both')) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    email TEXT,
    gender TEXT CHECK(gender IN ('male', 'female')) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status TEXT CHECK(status IN ('scheduled', 'completed', 'cancelled', 'no_show')) NOT NULL DEFAULT 'scheduled',
    total_price DECIMAL(10,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE appointment_services (
    appointment_service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

CREATE TABLE completed_services (
    completed_service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    completion_date DATE NOT NULL DEFAULT CURRENT_DATE,
    completion_time TIME NOT NULL DEFAULT CURRENT_TIME,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    commission_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

CREATE TABLE salary_periods (
    period_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_revenue DECIMAL(10,2) NOT NULL DEFAULT 0,
    commission_percent DECIMAL(5,2) NOT NULL,
    salary_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO employees (first_name, last_name, specialization, commission_percent, hire_date, is_active) VALUES
('Иван', 'Петров', 'male', 40.0, '2023-01-15', 1),
('Мария', 'Сидорова', 'female', 50.0, '2023-02-20', 1),
('Анна', 'Козлова', 'universal', 45.0, '2023-03-10', 1),
('Сергей', 'Иванов', 'male', 35.0, '2022-11-05', 0),
('Ольга', 'Николаева', 'female', 48.0, '2024-01-10', 1);

INSERT INTO services (name, duration_minutes, price, gender) VALUES
('Мужская стрижка', 30, 800.00, 'male'),
('Женская стрижка', 60, 1500.00, 'female'),
('Стрижка и укладка', 45, 1200.00, 'both'),
('Окрашивание волос', 90, 2500.00, 'female'),
('Бритье', 20, 500.00, 'male'),
('Детская стрижка', 25, 600.00, 'both'),
('Стрижка бороды', 15, 400.00, 'male'),
('Укладка', 30, 700.00, 'both');

INSERT INTO clients (first_name, last_name, phone, email, gender) VALUES
('Алексей', 'Смирнов', '+79161234567', 'alex@mail.ru', 'male'),
('Елена', 'Кузнецова', '+79162345678', 'elena@mail.ru', 'female'),
('Дмитрий', 'Попов', '+79163456789', 'dmitry@mail.ru', 'male'),
('Светлана', 'Васильева', '+79164567890', 'svetlana@mail.ru', 'female'),
('Михаил', 'Петров', '+79165678901', 'mikhail@mail.ru', 'male'),
('Анна', 'Соколова', '+79166789012', 'anna@mail.ru', 'female');

INSERT INTO appointments (employee_id, client_id, appointment_date, appointment_time, status, total_price) VALUES
(1, 1, '2024-05-20', '10:00', 'completed', 800.00),
(2, 2, '2024-05-20', '11:00', 'completed', 1500.00),
(3, 3, '2024-05-20', '12:00', 'scheduled', 1200.00),
(1, 4, '2024-05-20', '14:00', 'scheduled', 700.00),
(2, 5, '2024-05-21', '10:30', 'scheduled', 800.00);

INSERT INTO appointment_services (appointment_id, service_id, price) VALUES
(1, 1, 800.00),
(2, 2, 1500.00),
(3, 3, 1200.00),
(4, 8, 700.00),
(5, 1, 800.00);

INSERT INTO completed_services (appointment_id, employee_id, service_id, completion_date, completion_time, price, commission_amount) VALUES
(1, 1, 1, '2024-05-20', '10:30', 800.00, 320.00),
(2, 2, 2, '2024-05-20', '12:00', 1500.00, 750.00);

INSERT INTO salary_periods (employee_id, start_date, end_date, total_revenue, commission_percent, salary_amount) VALUES
(1, '2024-05-01', '2024-05-31', 5000.00, 40.0, 2000.00),
(2, '2024-05-01', '2024-05-31', 7500.00, 50.0, 3750.00),
(3, '2024-05-01', '2024-05-31', 3000.00, 45.0, 1350.00);

CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_employee_date ON appointments(employee_id, appointment_date);
CREATE INDEX idx_completed_services_date ON completed_services(completion_date);
CREATE INDEX idx_completed_services_employee_date ON completed_services(employee_id, completion_date);
CREATE INDEX idx_clients_phone ON clients(phone);