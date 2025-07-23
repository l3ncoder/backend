CREATE TABLE Patient (
    Patient_id DECIMAL PRIMARY KEY,
    Patient_name VARCHAR(1024) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL,   -- Assumed that Gender is a single character (e.g., 'M' or 'F')
    Address VARCHAR(1024) NOT NULL
);


CREATE TABLE Inpatientvisits2 (
    Encounter_id DECIMAL PRIMARY KEY,
    Patient_id DECIMAL REFERENCES Patient(Patient_id),
    Admission_datetime TIMESTAMP NOT NULL,
    Discharge_datetime TIMESTAMP NOT NULL,
    Death_ind BOOLEAN NOT NULL
);


INSERT INTO Patient (Patient_id, Patient_name, DOB, Gender, Address) VALUES
(1, 'John Doe', '1980-01-01', 'M', '123 Main St'),
(2, 'Jane Smith', '1990-05-15', 'F', '456 Elm St'),
(3, 'Alice Brown', '1985-03-10', 'F', '789 Oak St'),
(4, 'Bob White', '1975-07-20', 'M', '101 Maple Ave'),
(5, 'Charlie Black', '2000-12-25', 'M', '202 Pine St'),
(6, 'Diana Green', '1995-11-01', 'F', '303 Birch Blvd'),
(7, 'Evan Gray', '1988-06-30', 'M', '404 Cedar Rd'),
(8, 'Fiona Blue', '1992-08-14', 'F', '505 Spruce Ct'),
(9, 'George Yellow', '1970-09-19', 'M', '606 Fir Ln'),
(10, 'Hannah Violet', '1982-02-28', 'F', '707 Ash Dr');


INSERT INTO Inpatientvisits (Encounter_id, Patient_id, Admission_datetime, Discharge_datetime, Death_ind) VALUES
(13, 5, '2024-01-26 10:00:00', '2024-05-26 15:00:00', FALSE)


-- i.	Write a SQL statement that counts the number of inpatient visits for each patient in the hospital.
SELECT 
    p.Patient_id,
    p.Patient_name,
    COUNT(iv.Encounter_id) AS Number_of_Visits
FROM 
    Patient p
LEFT JOIN 
    Inpatientvisits iv
ON 
    p.Patient_id = iv.Patient_id
GROUP BY 
    p.Patient_id, p.Patient_name;
   
 
-- ii.	Write a SQL statement that produces the result that gives the earliest admission encounter (note: one patient can have multiple encounters) for each patient, also include all fields in the patient table. 
SELECT 
    p.Patient_id,
    p.Patient_name,
    p.DOB,
    p.Gender,
    p.Address,
    iv.Encounter_id,
    iv.Admission_datetime,
    iv.Discharge_datetime,
    iv.Death_ind
FROM 
    Patient p
JOIN 
    Inpatientvisits iv
ON 
    p.Patient_id = iv.Patient_id
WHERE 
    iv.Admission_datetime = (
        SELECT MIN(iv2.Admission_datetime)
        FROM Inpatientvisits iv2
        WHERE iv2.Patient_id = iv.Patient_id
    );

-- iii.	Write a SQL statement that produces the result that gives the admission encounter with the longest length of stay (number of days patient was hospitalized) with include all fields in the patient table and only patients who are still alive.
SELECT 
    p.Patient_id,
    p.Patient_name,
    p.DOB,
    p.Gender,
    p.Address,
    iv.Encounter_id,
    iv.Admission_datetime,
    iv.Discharge_datetime,
    iv.Death_ind,
    DATEDIFF(iv.Discharge_datetime, iv.Admission_datetime) AS Length_of_Stay
FROM 
    Patient p
JOIN 
    Inpatientvisits iv
ON 
    p.Patient_id = iv.Patient_id
WHERE 
    iv.Death_ind = FALSE
ORDER BY 
    Length_of_Stay DESC
LIMIT 1;

---iii mysql way for part 
SELECT 
    p.Patient_id,
    p.Patient_name,
    p.DOB,
    p.Gender,
    p.Address,
    iv.Encounter_id,
    iv.Admission_datetime,
    iv.Discharge_datetime,
    iv.Death_ind,
    EXTRACT(DAY FROM iv.Discharge_datetime - iv.Admission_datetime) AS Length_of_Stay
FROM 
    Patient p
JOIN 
    Inpatientvisits iv
ON 
    p.Patient_id = iv.Patient_id
WHERE 
    iv.Death_ind = FALSE
ORDER BY 
    Length_of_Stay DESC
LIMIT 1;


--iv.	We know want to know patients who have been re-admitted to the hospital where the second admission falls within this year. Write a SQL statement that produces the readmission encounter for this year. Provide patient details from the patient table as well.
SELECT 
    p.Patient_id,
    p.Patient_name,
    p.DOB,
    p.Gender,
    p.Address,
    iv.Encounter_id,
    iv.Admission_datetime,
    iv.Discharge_datetime,
    iv.Death_ind
FROM 
    Patient p
JOIN 
    Inpatientvisits iv
ON 
    p.Patient_id = iv.Patient_id
WHERE 
    iv.Admission_datetime > (
        SELECT MIN(iv2.Admission_datetime)
        FROM Inpatientvisits iv2
        WHERE iv2.Patient_id = iv.Patient_id
    )  -- Ensures it's the second admission
    AND EXTRACT(YEAR FROM iv.Admission_datetime) = EXTRACT(YEAR FROM CURRENT_DATE)  -- Filters for admissions this year
ORDER BY 
    iv.Admission_datetime;

   

