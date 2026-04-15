-- =============================================================
-- Smart Hospital Database Schema
-- Compatible with: PostgreSQL 16+
-- =============================================================

-- -------------------------------------------------------------
-- 1. PATIENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS patients (
    patient_id          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    gender              VARCHAR(10)     NOT NULL CHECK (gender IN ('Male','Female','Other')),
    date_of_birth       DATE            NOT NULL,
    contact_number      VARCHAR(20),
    email               VARCHAR(100),
    address             VARCHAR(200),
    insurance_provider  VARCHAR(100),
    insurance_number    VARCHAR(50),
    registration_date   DATE            NOT NULL DEFAULT CURRENT_DATE
);

-- -------------------------------------------------------------
-- 2. DOCTORS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name          VARCHAR(50)     NOT NULL,
    last_name           VARCHAR(50)     NOT NULL,
    specialization      VARCHAR(100)    NOT NULL,
    phone_number        VARCHAR(20),
    email               VARCHAR(100),
    years_experience    INT             DEFAULT 0,
    hospital_branch     VARCHAR(100)
);

-- -------------------------------------------------------------
-- 3. APPOINTMENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id          INT             NOT NULL,
    doctor_id           INT             NOT NULL,
    appointment_date    DATE            NOT NULL,
    appointment_time    TIME            NOT NULL,
    reason_for_visit    VARCHAR(200),
    status              VARCHAR(15)     NOT NULL DEFAULT 'Scheduled'
                                        CHECK (status IN ('Scheduled','Completed','Cancelled','No-Show')),
    CONSTRAINT fk_appt_patient  FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    CONSTRAINT fk_appt_doctor   FOREIGN KEY (doctor_id)   REFERENCES doctors(doctor_id)
);

-- -------------------------------------------------------------
-- 4. TREATMENTS
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS treatments (
    treatment_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id      INT             NOT NULL,
    patient_id          INT             NOT NULL,
    doctor_id           INT             NOT NULL,
    treatment_type      VARCHAR(100)    NOT NULL,
    diagnosis           VARCHAR(200),
    medications         VARCHAR(300),
    treatment_date      DATE            NOT NULL,
    notes               TEXT,
    CONSTRAINT fk_treat_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    CONSTRAINT fk_treat_patient     FOREIGN KEY (patient_id)     REFERENCES patients(patient_id),
    CONSTRAINT fk_treat_doctor      FOREIGN KEY (doctor_id)      REFERENCES doctors(doctor_id)
);

-- -------------------------------------------------------------
-- 5. BILLING
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing (
    billing_id          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id          INT             NOT NULL,
    appointment_id      INT             NOT NULL,
    billing_amount      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    payment_status      VARCHAR(15)     NOT NULL DEFAULT 'Pending'
                                        CHECK (payment_status IN ('Paid','Pending','Overdue','Cancelled')),
    payment_method      VARCHAR(20)     DEFAULT 'Cash'
                                        CHECK (payment_method IN ('Cash','Credit Card','Insurance','Online')),
    billing_date        DATE            NOT NULL,
    insurance_covered   DECIMAL(10,2)   DEFAULT 0.00,
    CONSTRAINT fk_bill_patient      FOREIGN KEY (patient_id)     REFERENCES patients(patient_id),
    CONSTRAINT fk_bill_appointment  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);
