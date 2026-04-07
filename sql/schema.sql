-- =============================================================
-- Smart Hospital Database Schema
-- Compatible with: MySQL 8.x
-- =============================================================

CREATE DATABASE IF NOT EXISTS smart_hospital
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE smart_hospital;

-- -------------------------------------------------------------
-- 1. PATIENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS patients (
    patient_id          INT             NOT NULL AUTO_INCREMENT,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    gender              ENUM('Male','Female','Other') NOT NULL,
    date_of_birth       DATE            NOT NULL,
    contact_number      VARCHAR(20),
    email               VARCHAR(100),
    address             VARCHAR(200),
    insurance_provider  VARCHAR(100),
    insurance_number    VARCHAR(50),
    registration_date   DATE            NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (patient_id)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 2. DOCTORS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id           INT             NOT NULL AUTO_INCREMENT,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    specialization      VARCHAR(100)    NOT NULL,
    phone_number        VARCHAR(20),
    email               VARCHAR(100),
    years_experience    INT             DEFAULT 0,
    hospital_branch     VARCHAR(100),
    PRIMARY KEY (doctor_id)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 3. APPOINTMENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id      INT             NOT NULL AUTO_INCREMENT,
    patient_id          INT             NOT NULL,
    doctor_id           INT             NOT NULL,
    appointment_date    DATE            NOT NULL,
    appointment_time    TIME            NOT NULL,
    reason_for_visit    VARCHAR(200),
    status              ENUM('Scheduled','Completed','Cancelled','No-Show')
                                        NOT NULL DEFAULT 'Scheduled',
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appt_patient  FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    CONSTRAINT fk_appt_doctor   FOREIGN KEY (doctor_id)   REFERENCES doctors(doctor_id)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 4. TREATMENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS treatments (
    treatment_id        INT             NOT NULL AUTO_INCREMENT,
    appointment_id      INT             NOT NULL,
    patient_id          INT             NOT NULL,
    doctor_id           INT             NOT NULL,
    treatment_type      VARCHAR(100)    NOT NULL,
    diagnosis           VARCHAR(200),
    medications         VARCHAR(300),
    treatment_date      DATE            NOT NULL,
    notes               TEXT,
    PRIMARY KEY (treatment_id),
    CONSTRAINT fk_treat_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    CONSTRAINT fk_treat_patient     FOREIGN KEY (patient_id)     REFERENCES patients(patient_id),
    CONSTRAINT fk_treat_doctor      FOREIGN KEY (doctor_id)      REFERENCES doctors(doctor_id)
) ENGINE=InnoDB;

-- -------------------------------------------------------------
-- 5. BILLING
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing (
    billing_id          INT             NOT NULL AUTO_INCREMENT,
    patient_id          INT             NOT NULL,
    appointment_id      INT             NOT NULL,
    billing_amount      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    payment_status      ENUM('Paid','Pending','Overdue','Cancelled')
                                        NOT NULL DEFAULT 'Pending',
    payment_method      ENUM('Cash','Credit Card','Insurance','Online')
                                        DEFAULT 'Cash',
    billing_date        DATE            NOT NULL,
    insurance_covered   DECIMAL(10,2)   DEFAULT 0.00,
    PRIMARY KEY (billing_id),
    CONSTRAINT fk_bill_patient      FOREIGN KEY (patient_id)     REFERENCES patients(patient_id),
    CONSTRAINT fk_bill_appointment  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
) ENGINE=InnoDB;
