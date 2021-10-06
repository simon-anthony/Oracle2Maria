-- vim: syntax=sql:ts=4:sw=4:

CREATE OR REPLACE
PROCEDURE add_job_history (
	p_emp_id          HR.job_history.employee_id%TYPE,
	p_start_date      HR.job_history.start_date%TYPE,
	p_end_date        HR.job_history.end_date%TYPE,
	p_job_id          HR.job_history.job_id%TYPE,
	p_department_id   HR.job_history.department_id%TYPE)
IS
BEGIN
	INSERT INTO HR.job_history(employee_id, start_date, end_date, job_id, department_id)
	VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END;
/

CREATE OR REPLACE
PROCEDURE secure_dml
IS
BEGIN
	IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN')
	THEN
        RAISE_APPLICATION_ERROR(-20205, 'You may only make changes during normal office hours');
	END IF;
END;
/

CREATE OR REPLACE
PACKAGE emp_pkg
IS
	FUNCTION update_esal_func(
		deptid			employees.department_id%TYPE,
		esal			employees.salary%TYPE,
		hike_percent	NUMBER)
	RETURN employees.salary%TYPE;

	PROCEDURE implement_dept_raise(
		deptid			employees.department_id%TYPE,
		hike_percent	NUMBER);
END emp_pkg;
/

CREATE OR REPLACE
PACKAGE BODY emp_pkg
IS
	FUNCTION update_esal_func(
		deptid			employees.department_id%TYPE,
		esal			employees.salary%TYPE,
		hike_percent	NUMBER)
	RETURN employees.salary%TYPE
	IS
		new_sal employees.salary%TYPE;
	BEGIN
		new_sal := esal + (esal * hike_percent)/100;
		RETURN new_sal;
	END update_esal_func;

	PROCEDURE implement_dept_raise(
		deptid			employees.department_id%TYPE,
		hike_percent	NUMBER)
	IS
		res_sal			employees.salary%TYPE;
		CURSOR cur_emp IS
			SELECT *
			FROM employees
			WHERE department_id = deptid
			FOR UPDATE;
		rec_emp			cur_emp%ROWTYPE;
		new_sal			NUMBER(12,2);
	BEGIN
		OPEN cur_emp;
		LOOP
			FETCH cur_emp INTO rec_emp;
			EXIT WHEN cur_emp%NOTFOUND;
			res_sal := update_esal_func(rec_emp.department_id,rec_emp.salary,hike_percent);
			UPDATE employees SET salary  = res_sal WHERE CURRENT OF cur_emp;
		END LOOP;
		CLOSE cur_emp;
	END implement_dept_raise;

END emp_pkg;
/

CREATE OR REPLACE FORCE
VIEW error_view(country_id, region_id, bitandtest)
AS
	SELECT country_id, region_id, BITAND(10111,10101) bitandtest
	FROM countries;

