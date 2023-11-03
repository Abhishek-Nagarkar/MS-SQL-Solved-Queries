-- CREATE PROCEDURES

use hospitaldb;

-- Q1.
GO
CREATE PROCEDURE UPDATE_PHONE_NUMBER (
	@patient_id VARCHAR(10),
	@contact_number VARCHAR(10)
	)
AS 
BEGIN
	DECLARE @patient_found VARCHAR(10)
	SELECT @patient_found=patient_id FROM Patient WHERE patient_id=@patient_id
	IF(@patient_found IS NULL)
		PRINT('ID NOT FOUND')
	ELSE
		UPDATE Patient SET contact_number=@contact_number WHERE patient_id=@patient_id
		PRINT('PATIENT DETAILS UPDATED')
END

DECLARE @patient_id VARCHAR(10), @cnc VARCHAR(10)
SET @patient_id = 'P001'
SET @cnc='9766980341'
EXEC DBO.UPDATE_PHONE_NUMBER @patient_id, @cnc

----------------------------------------
--- Q2
CREATE PROCEDURE SHOW_PATIENT_BILL 
AS
BEGIN
	SELECT 
	P.patient_id AS 'PATIENT ID', 
	P.p_first_name AS 'FIRST NAME',
	P.address AS 'ADDRESS',
	A.app_number AS 'APPOINTMENT NUMBER',
	B.bill_amount AS 'BILL AMOUNT',
	B.bill_status AS 'BILL STATUS'
	FROM Patient P 
	JOIN Appointment A ON A.patient_id=P.patient_id
	JOIN Bill B ON B.app_number=A.app_number
	WHERE B.bill_status='NOT PAID'
	ORDER BY A.app_number DESC
END

EXEC SHOW_PATIENT_BILL
------------------------------------
-- Q3
CREATE PROCEDURE DOCTOR_APPOINTMENT_RECORD 
AS
BEGIN
	SELECT D.doctor_id, CONCAT('Dr. ', D.dr_first_name,' ', D.dr_last_name) AS 'DOCTOR NAME'  FROM Doctor D 
	LEFT JOIN Appointment A ON A.doctor_id=D.doctor_id
	WHERE A.doctor_id IS NULL
	ORDER BY D.doctor_id DESC
END

EXEC DOCTOR_APPOINTMENT_RECORD

------------------------
-- Q4

CREATE PROCEDURE APPOINTMENTS_BY_CITY ( 
	@City VARCHAR(10)
)
AS
BEGIN
	SELECT 
	CONCAT(P.p_first_name, ' ',P.p_middle_name, ' ', P.p_last_name,' ') AS 'PATIENT NAME',
	A.app_date AS 'APPOINTMENT DATE', 
	CONCAT('Dr.' ,D.dr_first_name, ' ', D.dr_middle_name, ' ', D.dr_last_name) AS 'DOCTOR NAME'
	FROM Patient P 
	JOIN Appointment A ON A.patient_id=P.patient_id
	JOIN Doctor D ON D.doctor_id=A.doctor_id
	WHERE P.city=@City
END

DECLARE @City VARCHAR(10)
SET @City='PUNE'
EXEC APPOINTMENTS_BY_CITY @city
	

---------------------------------
-- Q5.

CREATE PROCEDURE SHOW_PATIENT_BILL (
	@patient_id VARCHAR(10),
	@total_bill_amount INT OUTPUT
)
AS
BEGIN
	SELECT @total_bill_amount=SUM(B.bill_amount) 
	FROM Patient P 
	JOIN Appointment A ON A.patient_id=P.patient_id
	JOIN Bill B ON B.app_number=A.app_number
	WHERE P.patient_id=@patient_id
END

DECLARE @pat_id VARCHAR(10)
DECLARE @total int
SET @pat_id='P001'
exec SHOW_PATIENT_BILL @pat_id, @total output
PRINT CONCAT('PATIENT ID: ', @pat_id, ' , Total Bill: ', @total)

----------------------------------------------------------------------------------------------------
-- CREATE VIEWS

-- Q1.
CREATE VIEW V_APPOINTMENT_INFO 
AS
SELECT P.p_first_name, P.p_last_name, P.p_age, D.dr_first_name, A.app_date, A.app_time FROM Patient P
JOIN Appointment A ON A.patient_id=P.patient_id
JOIN Doctor D ON A.doctor_id=D.doctor_id

SELECT * FROM V_APPOINTMENT_INFO

------------------------------------

--Q2. 
CREATE VIEW V_PATIENT_BILLING_INFO 
AS
SELECT P.patient_id AS 'PATIENT ID'
, CONCAT(P.p_first_name, ' ', P.p_middle_name, ' ', P.p_last_name) AS 'PATIENT NAME',
P.p_age AS 'AGE', P.address AS 'ADDRESS',
P.city AS 'CITY', P.contact_number AS 'CONTACT NUMBER',
B.bill_number, B.bill_amount,
B.bill_date, B.bill_status,
PY.payment_id, PY.pay_date,
PY.pay_mode, PY.pay_amount
FROM Patient P
JOIN Appointment A ON A.patient_id=P.patient_id
JOIN Bill B ON B.app_number = A.app_number
JOIN Payment PY ON PY.bill_number=B.bill_number

SELECT * FROM V_PATIENT_BILLING_INFO
--------------------------------

-- Q3.
CREATE VIEW V_DOCTOR_APPOINTMENT_DETAILS AS
SELECT 
CONCAT('Dr. ', D.dr_first_name, ' ', D.dr_middle_name,' ', D.dr_last_name) AS 'DOCTOR NAME',
A.app_date AS 'APPOINTMENT DATE',
A.app_reason AS 'APPOINTMENT REASON',
A.app_time AS 'APPOINTMENT TIME'
FROM Doctor D
JOIN Appointment A ON A.doctor_id=D.doctor_id

SELECT * FROM V_DOCTOR_APPOINTMENT_DETAILS
----------------------------------------

--Q4. 
CREATE VIEW V_DOCTOR_PATIENT_APPOINTMENT_DETAIL AS
SELECT 
CONCAT('Dr. ', D.dr_first_name, ' ', D.dr_middle_name,' ', D.dr_last_name) AS 'DOCTOR NAME',
CONCAT(P.p_first_name,' ', P.p_middle_name, ' ', P.p_last_name) AS 'PATIENT NAME',
A.app_date AS 'APPOINTMENT DATE',
A.app_time AS 'APPOINTMENT TIME',
A.app_reason AS 'APPOINTMENT REASON'
FROM Doctor D
JOIN Appointment A ON A.doctor_id=D.doctor_id
JOIN Patient P ON A.patient_id=P.patient_id

SELECT * FROM V_DOCTOR_PATIENT_APPOINTMENT_DETAIL


-------------------------------
-- Q5. CREATE VIEW WITH PATIENT DETAILS AND PAYMENT WHO HAVE PAID THE BILL
CREATE VIEW V_PATIENT_BILL_PAID AS
SELECT 
P.patient_id,
CONCAT(P.p_first_name,' ', P.p_middle_name, ' ', P.p_last_name) AS 'PATIENT NAME',
P.address AS 'ADDRESS', P.city AS 'CITY',
P.contact_number AS 'CONTACT DETAILS', P.p_age AS 'AGE',
PY.bill_number AS 'BILL NUMBER', PY.pay_mode AS 'MODE OF PAYMENT',
PY.pay_date AS 'PAID ON', PY.pay_amount AS 'AMOUNT',
PY.payment_id AS 'PAYMENT ID'
FROM Patient P
JOIN Appointment A ON A.patient_id=P.patient_id
JOIN Bill B ON B.app_number=A.app_number
JOIN Payment PY ON PY.bill_number=B.bill_number
WHERE PY.pay_mode IS NOT NULL

SELECT * FROM V_PATIENT_BILL_PAID