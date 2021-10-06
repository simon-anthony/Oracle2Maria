-- vim: syntax=sql:ts=4:sw=4:

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
			res_sal := update_esal_func(rec_emp.department_id, rec_emp.salary, hike_percent);
			UPDATE employees SET salary = res_sal WHERE employee_id = rec_emp.employee_id;
		END LOOP;
		CLOSE cur_emp;
	END implement_dept_raise;

END emp_pkg;
/

/*
CREATE OR REPLACE FORCE
VIEW error_view(country_id, region_id, bitandtest)
AS
	SELECT country_id, region_id, BITAND(10111,10101) bitandtest
	FROM countries;
*/
