-- Shared MySQL schema for Hospital Management (Hibernate + Node API)
-- Run: mysql -u root -p < schema.sql

CREATE DATABASE IF NOT EXISTS hospital_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hospital_db;

-- App user for both Java (Hibernate) and Node API
-- If you prefer to use root, you can skip these statements.
CREATE USER IF NOT EXISTS 'hospital_user'@'localhost' IDENTIFIED BY 'hospital123';
GRANT ALL PRIVILEGES ON hospital_db.* TO 'hospital_user'@'localhost';
FLUSH PRIVILEGES;

DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctor_slots;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS doctors;

CREATE TABLE patients (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(30) NULL,
  password_hash VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE doctors (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  specialty VARCHAR(100) NULL,
  password_hash VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE doctor_slots (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  doctor_id BIGINT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  is_booked TINYINT NOT NULL DEFAULT 0,
  CONSTRAINT fk_slot_doctor FOREIGN KEY (doctor_id) REFERENCES doctors (id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE appointments (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  slot_id BIGINT NULL,
  appointment_time DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
  reminder_sent TINYINT NOT NULL DEFAULT 0,
  notes TEXT NULL,
  CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES doctors (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_appt_slot FOREIGN KEY (slot_id) REFERENCES doctor_slots (id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE patient_documents (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  uploader_id BIGINT NOT NULL, -- Either patient or doctor who uploaded it
  uploader_role VARCHAR(20) NOT NULL DEFAULT 'PATIENT',
  filename VARCHAR(255) NOT NULL,
  filepath VARCHAR(512) NOT NULL,
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doc_patient FOREIGN KEY (patient_id) REFERENCES patients (id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE prescriptions (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  appointment_id BIGINT NOT NULL,
  medication VARCHAR(255) NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  instructions TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rx_appointment FOREIGN KEY (appointment_id) REFERENCES appointments (id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  user_type VARCHAR(20) NOT NULL, -- 'PATIENT' or 'DOCTOR'
  message TEXT NOT NULL,
  is_read TINYINT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Demo password for all seeded accounts: password123 (bcrypt)
INSERT INTO patients (name, email, phone, password_hash) VALUES
  ('Alice Patient', 'alice@patient.com', '555-0101',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Bob Patient', 'bob@patient.com', '555-0102',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Carol Patient', 'carol@patient.com', '555-0103',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('David Patient', 'david@patient.com', '555-0104',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Emma Patient', 'emma@patient.com', '555-0105',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C');

INSERT INTO doctors (name, email, specialty, password_hash) VALUES
  ('Dr. Smith', 'dr.smith@hospital.com', 'General Medicine',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Dr. Jones', 'dr.jones@hospital.com', 'Cardiology',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Dr. Brown', 'dr.brown@hospital.com', 'Dermatology',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C'),
  ('Dr. Wilson', 'dr.wilson@hospital.com', 'Orthopedics',
   '$2a$10$YYpWXb0A25W44UehDycEZedcb6u0sjWiahnFhgLa6DFqQQC/62n8C');

-- Example open slots (next few days)
INSERT INTO doctor_slots (doctor_id, start_time, end_time, is_booked) VALUES
  (1, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 9 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 9 HOUR + INTERVAL 30 MINUTE, 0),
  (1, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 10 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 10 HOUR + INTERVAL 30 MINUTE, 0),
  (2, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 14 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 14 HOUR + INTERVAL 30 MINUTE, 0),
  (2, DATE_ADD(CURDATE(), INTERVAL 4 DAY) + INTERVAL 11 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 4 DAY) + INTERVAL 11 HOUR + INTERVAL 30 MINUTE, 0),
  (3, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 16 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 16 HOUR + INTERVAL 30 MINUTE, 0),
  (3, DATE_ADD(CURDATE(), INTERVAL 5 DAY) + INTERVAL 9 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 5 DAY) + INTERVAL 9 HOUR + INTERVAL 30 MINUTE, 0),
  (4, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 13 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 13 HOUR + INTERVAL 30 MINUTE, 0),
  (4, DATE_ADD(CURDATE(), INTERVAL 6 DAY) + INTERVAL 15 HOUR,
      DATE_ADD(CURDATE(), INTERVAL 6 DAY) + INTERVAL 15 HOUR + INTERVAL 30 MINUTE, 0);

-- Seed a few appointments so dashboards are not empty
INSERT INTO appointments (patient_id, doctor_id, slot_id, appointment_time, status, notes)
SELECT 1, 1, id, start_time, 'SCHEDULED', 'Routine checkup'
FROM doctor_slots WHERE doctor_id = 1 ORDER BY id LIMIT 1;

INSERT INTO appointments (patient_id, doctor_id, slot_id, appointment_time, status, notes)
SELECT 2, 2, id, start_time, 'SCHEDULED', 'Chest pain follow-up'
FROM doctor_slots WHERE doctor_id = 2 ORDER BY id LIMIT 1;

INSERT INTO appointments (patient_id, doctor_id, slot_id, appointment_time, status, notes)
SELECT 3, 3, id, start_time, 'SCHEDULED', 'Skin allergy consultation'
FROM doctor_slots WHERE doctor_id = 3 ORDER BY id LIMIT 1;

UPDATE appointments SET status = 'CONFIRMED' WHERE id = 2;
UPDATE appointments SET status = 'COMPLETED' WHERE id = 3;

-- Mark booked slots based on seeded appointments
UPDATE doctor_slots s
JOIN appointments a ON a.slot_id = s.id
SET s.is_booked = 1;
