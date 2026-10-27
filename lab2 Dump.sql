-- Requires MySQL 8.0+ (uses recursive CTE)
DROP DATABASE IF EXISTS hms_db;
CREATE DATABASE hms_db;
USE hms_db;

-- =========================================================
-- TABLES
-- =========================================================
CREATE TABLE department (
    department_id   INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE,
    location        VARCHAR(100),
    PRIMARY KEY (department_id)
);

CREATE TABLE doctor (
    doctor_id      INT NOT NULL AUTO_INCREMENT,
    name           VARCHAR(100),
    specialization VARCHAR(100),
    phone          VARCHAR(20),
    department_id  INT,
    PRIMARY KEY (doctor_id)
);

CREATE TABLE patient (
    patient_id    INT NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100),
    date_of_birth DATE,
    gender        VARCHAR(10),
    phone         VARCHAR(20),
    email         VARCHAR(150) UNIQUE,
    PRIMARY KEY (patient_id)
);

CREATE TABLE room (
    room_id     INT NOT NULL AUTO_INCREMENT,
    room_number VARCHAR(20) UNIQUE,
    room_type   VARCHAR(50),
    status      VARCHAR(30),
    PRIMARY KEY (room_id)
);

CREATE TABLE medication (
    medication_id   INT NOT NULL AUTO_INCREMENT,
    medication_name VARCHAR(100),
    dosage          VARCHAR(50),
    manufacturer    VARCHAR(100),
    PRIMARY KEY (medication_id)
);

CREATE TABLE appointment (
    appointment_id   INT NOT NULL AUTO_INCREMENT,
    patient_id       INT,
    doctor_id        INT,
    appointment_date TIMESTAMP NULL,
    status           VARCHAR(30),
    PRIMARY KEY (appointment_id)
);

CREATE TABLE admission (
    admission_id   INT NOT NULL AUTO_INCREMENT,
    patient_id     INT,
    room_id        INT,
    admission_date DATE,
    discharge_date DATE,
    PRIMARY KEY (admission_id)
);

CREATE TABLE prescription (
    prescription_id   INT NOT NULL AUTO_INCREMENT,
    patient_id        INT,
    doctor_id         INT,
    prescription_date DATE,
    PRIMARY KEY (prescription_id)
);

CREATE TABLE prescription_medication (
    prescription_id INT,
    medication_id   INT,
    quantity        INT,
    instructions    VARCHAR(255),
    PRIMARY KEY (prescription_id, medication_id)
);

-- =========================================================
-- FOREIGN KEYS (child -> parent; the original ones were reversed)
-- =========================================================
ALTER TABLE doctor
    ADD FOREIGN KEY (department_id) REFERENCES department(department_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE appointment
    ADD FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION,
    ADD FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE admission
    ADD FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION,
    ADD FOREIGN KEY (room_id) REFERENCES room(room_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE prescription
    ADD FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION,
    ADD FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE prescription_medication
    ADD FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION,
    ADD FOREIGN KEY (medication_id) REFERENCES medication(medication_id)
    ON UPDATE NO ACTION ON DELETE NO ACTION;

-- =========================================================
-- DATA (50 rows per table, inserted parents-first)
-- =========================================================
CREATE TABLE nums (n INT PRIMARY KEY);
INSERT INTO nums
WITH RECURSIVE seq AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 50
)
SELECT n FROM seq;

-- department
INSERT INTO department (department_name, location)
SELECT
    ELT(n,
        'Cardiology','Neurology','Oncology','Pediatrics','Orthopedics',
        'Dermatology','Gastroenterology','Nephrology','Urology','Pulmonology',
        'Endocrinology','Rheumatology','Hematology','Ophthalmology','ENT',
        'Psychiatry','Radiology','Emergency Medicine','Anesthesiology','General Surgery',
        'Obstetrics','Gynecology','Neonatology','Geriatrics','Infectious Diseases',
        'Pathology','Physical Therapy','Plastic Surgery','Vascular Surgery','Neurosurgery',
        'Cardiothoracic Surgery','Pain Management','Allergy and Immunology','Sleep Medicine','Nutrition and Dietetics',
        'Dental Surgery','Critical Care','Palliative Care','Sports Medicine','Family Medicine',
        'Internal Medicine','Transplant Surgery','Clinical Genetics','Rehabilitation','Nuclear Medicine',
        'Interventional Radiology','Laboratory Medicine','Pharmacy Services','Occupational Health','Public Health'),
    CONCAT('Building ', ELT(n % 5 + 1, 'A','B','C','D','E'), ', Floor ', n % 6 + 1)
FROM nums ORDER BY n;

-- doctor
INSERT INTO doctor (name, specialization, phone, department_id)
SELECT
    CONCAT('Dr. ',
        ELT((n - 1) % 20 + 1,
            'Ahmed','Mohammed','Omar','Khalid','Yusuf','Ali','Hassan','Ibrahim','Tariq','Faisal',
            'Fatima','Aisha','Maryam','Sara','Noor','Layla','Huda','Zainab','Amina','Reem'),
        ' ',
        ELT((n * 7) % 20 + 1,
            'Al-Harbi','Al-Qahtani','Al-Ghamdi','Al-Otaibi','Al-Zahrani','Al-Shehri','Al-Dosari','Al-Mutairi','Al-Subaie','Al-Anazi',
            'Khan','Siddiqui','Rahman','Hussain','Malik','Farouk','Nasser','Saleh','Qureshi','Bakr')),
    ELT((n - 1) % 10 + 1,
        'Cardiologist','Neurologist','Oncologist','Pediatrician','Orthopedic Surgeon',
        'Dermatologist','Gastroenterologist','Psychiatrist','Radiologist','General Practitioner'),
    CONCAT('05', LPAD((n * 7919311) % 100000000, 8, '0')),
    (n - 1) % 25 + 1
FROM nums ORDER BY n;

-- patient
INSERT INTO patient (name, date_of_birth, gender, phone, email)
SELECT
    CONCAT(
        ELT((n - 1) % 20 + 1,
            'Abdullah','Saad','Nasser','Fahad','Salman','Majed','Rayan','Hamza','Bilal','Zaid',
            'Hind','Salma','Dalal','Rana','Lina','Nadia','Jood','Asma','Mona','Shahd'),
        ' ',
        ELT((n * 3) % 20 + 1,
            'Al-Harbi','Al-Qahtani','Al-Ghamdi','Al-Otaibi','Al-Zahrani','Al-Shehri','Al-Dosari','Al-Mutairi','Al-Subaie','Al-Anazi',
            'Khan','Siddiqui','Rahman','Hussain','Malik','Farouk','Nasser','Saleh','Qureshi','Bakr')),
    DATE_SUB('2025-01-01', INTERVAL (n * 431 + 3000) DAY),
    IF((n - 1) % 20 < 10, 'Male', 'Female'),
    CONCAT('05', LPAD((n * 6271933) % 100000000, 8, '0')),
    CONCAT('patient', n, '@example.com')
FROM nums ORDER BY n;

-- room
INSERT INTO room (room_number, room_type, status)
SELECT
    CAST(100 * ((n - 1) DIV 10 + 1) + (n - 1) % 10 + 1 AS CHAR),
    ELT(n % 4 + 1, 'General', 'Private', 'ICU', 'Semi-Private'),
    ELT(n % 3 + 1, 'Available', 'Occupied', 'Maintenance')
FROM nums ORDER BY n;

-- medication
INSERT INTO medication (medication_name, dosage, manufacturer)
SELECT
    ELT((n - 1) % 25 + 1,
        'Paracetamol','Ibuprofen','Amoxicillin','Azithromycin','Metformin',
        'Atorvastatin','Amlodipine','Lisinopril','Omeprazole','Salbutamol',
        'Cetirizine','Losartan','Aspirin','Clopidogrel','Insulin Glargine',
        'Levothyroxine','Prednisolone','Diclofenac','Ciprofloxacin','Warfarin',
        'Furosemide','Sertraline','Loratadine','Pantoprazole','Gabapentin'),
    ELT(n % 4 + 1, '250 mg', '500 mg', '10 mg', '5 mg'),
    ELT(n % 6 + 1, 'Pfizer', 'Novartis', 'Saudi Pharmaceutical Industries', 'GSK', 'Sanofi', 'Tabuk Pharmaceuticals')
FROM nums ORDER BY n;

-- appointment
INSERT INTO appointment (patient_id, doctor_id, appointment_date, status)
SELECT
    (n * 3) % 50 + 1,
    (n * 7) % 50 + 1,
    DATE_ADD('2026-09-01 08:00:00', INTERVAL (n * 29 - 700) HOUR),
    ELT(n % 4 + 1, 'Scheduled', 'Completed', 'Cancelled', 'No-Show')
FROM nums ORDER BY n;

-- admission
INSERT INTO admission (patient_id, room_id, admission_date, discharge_date)
SELECT
    (n * 7) % 50 + 1,
    n,
    DATE_ADD('2026-01-01', INTERVAL n * 5 DAY),
    IF(n % 10 = 0, NULL, DATE_ADD('2026-01-01', INTERVAL n * 5 + 2 + n % 9 DAY))
FROM nums ORDER BY n;

-- prescription
INSERT INTO prescription (patient_id, doctor_id, prescription_date)
SELECT
    (n * 11) % 50 + 1,
    (n * 13) % 50 + 1,
    DATE_ADD('2026-01-10', INTERVAL n * 5 DAY)
FROM nums ORDER BY n;

-- prescription_medication
INSERT INTO prescription_medication (prescription_id, medication_id, quantity, instructions)
SELECT
    n,
    (n * 7) % 50 + 1,
    5 + (n % 6) * 5,
    ELT(n % 5 + 1,
        'Take once daily after breakfast',
        'Take twice daily with food',
        'Take three times daily after meals',
        'Take one tablet at bedtime',
        'Take every 8 hours as needed for pain')
FROM nums ORDER BY n;

DROP TABLE nums;

-- Quick check: each should return 50
SELECT 'department' AS tbl, COUNT(*) AS cnt FROM department
UNION ALL SELECT 'doctor', COUNT(*) FROM doctor
UNION ALL SELECT 'patient', COUNT(*) FROM patient
UNION ALL SELECT 'room', COUNT(*) FROM room
UNION ALL SELECT 'medication', COUNT(*) FROM medication
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'admission', COUNT(*) FROM admission
UNION ALL SELECT 'prescription', COUNT(*) FROM prescription
UNION ALL SELECT 'prescription_medication', COUNT(*) FROM prescription_medication;