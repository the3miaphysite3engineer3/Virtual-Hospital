-- =============================================================
-- Smart Hospital — Analysis Queries
-- Run AFTER schema.sql + seed_data.sql
-- =============================================================

-- ---------------------------------------------------------------
-- SECTION 1: PATIENT ANALYTICS
-- ---------------------------------------------------------------

-- 1.1  Total number of patients
SELECT COUNT(*) AS total_patients
FROM patients;

-- 1.2  Gender distribution
SELECT gender, COUNT(*) AS total
FROM patients
GROUP BY gender;

-- 1.3  Patients by age group
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 30 THEN '18 – 29'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 45 THEN '30 – 44'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 60 THEN '45 – 59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total
FROM patients
GROUP BY age_group
ORDER BY CASE age_group
    WHEN 'Under 18' THEN 1
    WHEN '18 – 29' THEN 2
    WHEN '30 – 44' THEN 3
    WHEN '45 – 59' THEN 4
    ELSE 5
END;

-- 1.4  Patients by insurance provider
SELECT
    COALESCE(NULLIF(insurance_provider,''), 'Uninsured') AS provider,
    COUNT(*) AS total
FROM patients
GROUP BY provider
ORDER BY total DESC;

-- 1.5  New patient registrations per month
SELECT
    TO_CHAR(registration_date, 'YYYY-MM') AS month,
    COUNT(*)                                 AS new_patients
FROM patients
GROUP BY month
ORDER BY month;

-- ---------------------------------------------------------------
-- SECTION 2: DOCTOR ANALYTICS
-- ---------------------------------------------------------------

-- 2.1  Total number of doctors
SELECT COUNT(*) AS total_doctors FROM doctors;

-- 2.2  Doctors by specialization
SELECT specialization, COUNT(*) AS total
FROM doctors
GROUP BY specialization
ORDER BY total DESC;

-- 2.3  Top 5 doctors by number of appointments
SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id)                 AS total_appointments
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY total_appointments DESC
LIMIT 5;

-- 2.4  Average experience by specialization
SELECT specialization, ROUND(AVG(years_experience), 1) AS avg_years
FROM doctors
GROUP BY specialization
ORDER BY avg_years DESC;

-- ---------------------------------------------------------------
-- SECTION 3: APPOINTMENT ANALYTICS
-- ---------------------------------------------------------------

-- 3.1  Total appointments
SELECT COUNT(*) AS total_appointments FROM appointments;

-- 3.2  Appointments by status
SELECT status, COUNT(*) AS total
FROM appointments
GROUP BY status
ORDER BY total DESC;

-- 3.3  Appointments per month (trend chart)
SELECT
    TO_CHAR(appointment_date, 'YYYY-MM') AS month,
    COUNT(*)                                AS total_appointments
FROM appointments
GROUP BY month
ORDER BY month;

-- 3.4  Appointments per weekday (peak day analysis)
SELECT
    TRIM(TO_CHAR(appointment_date, 'Day')) AS weekday,
    COUNT(*)                   AS total
FROM appointments
GROUP BY weekday
ORDER BY EXTRACT(DOW FROM appointment_date);

-- 3.5  Cancellation & No-Show rate
SELECT
    ROUND(SUM(CASE WHEN status IN ('Cancelled','No-Show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
        AS cancellation_rate_pct
FROM appointments;

-- 3.6  Patients with most appointments
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COUNT(a.appointment_id)                 AS total_appointments
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, patient_name
ORDER BY total_appointments DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- SECTION 4: TREATMENT ANALYTICS
-- ---------------------------------------------------------------

-- 4.1  Total treatments performed
SELECT COUNT(*) AS total_treatments FROM treatments;

-- 4.2  Most common treatment types
SELECT treatment_type, COUNT(*) AS total
FROM treatments
GROUP BY treatment_type
ORDER BY total DESC;

-- 4.3  Most common diagnoses
SELECT diagnosis, COUNT(*) AS total
FROM treatments
GROUP BY diagnosis
ORDER BY total DESC
LIMIT 10;

-- 4.4  Treatments by doctor
SELECT
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(t.treatment_id)                   AS total_treatments
FROM doctors d
JOIN treatments t ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY total_treatments DESC;

-- ---------------------------------------------------------------
-- SECTION 5: BILLING / REVENUE ANALYTICS
-- ---------------------------------------------------------------

-- 5.1  Total hospital revenue
SELECT
    SUM(billing_amount)    AS gross_revenue,
    SUM(insurance_covered) AS insurance_covered,
    SUM(billing_amount - insurance_covered) AS net_patient_paid
FROM billing;

-- 5.2  Revenue by payment method
SELECT payment_method, SUM(billing_amount) AS total_revenue
FROM billing
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 5.3  Revenue by payment status
SELECT payment_status, SUM(billing_amount) AS total, COUNT(*) AS invoices
FROM billing
GROUP BY payment_status
ORDER BY total DESC;

-- 5.4  Monthly revenue trend
SELECT
    TO_CHAR(billing_date, 'YYYY-MM') AS month,
    SUM(billing_amount)                 AS monthly_revenue
FROM billing
GROUP BY month
ORDER BY month;

-- 5.5  Top 10 highest-spending patients
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    SUM(b.billing_amount)                   AS total_spent
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, patient_name
ORDER BY total_spent DESC
LIMIT 10;

-- 5.6  Revenue per doctor (via appointments → billing)
SELECT
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    SUM(b.billing_amount)                   AS generated_revenue
FROM doctors d
JOIN appointments a ON d.doctor_id  = a.doctor_id
JOIN billing    b ON a.appointment_id = b.appointment_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY generated_revenue DESC;

-- 5.7  Average bill amount per treatment type
SELECT
    t.treatment_type,
    ROUND(AVG(b.billing_amount), 2) AS avg_bill
FROM treatments t
JOIN billing b ON t.appointment_id = b.appointment_id
GROUP BY t.treatment_type
ORDER BY avg_bill DESC;

-- ---------------------------------------------------------------
-- SECTION 6: SMART HOSPITAL KPI SUMMARY
-- ---------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM patients)                  AS total_patients,
    (SELECT COUNT(*) FROM doctors)                   AS total_doctors,
    (SELECT COUNT(*) FROM appointments)              AS total_appointments,
    (SELECT COUNT(*) FROM treatments)                AS total_treatments,
    (SELECT ROUND(SUM(billing_amount), 2) FROM billing) AS total_revenue_egp,
    (SELECT ROUND(AVG(billing_amount), 2) FROM billing) AS avg_bill_egp,
    (SELECT ROUND(SUM(CASE WHEN status IN ('Cancelled','No-Show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
     FROM appointments)                              AS cancellation_rate_pct;
