
CREATE OR REPLACE FUNCTION bytea_import(p_path TEXT, p_result out BYTEA)
LANGUAGE plpgsql AS 
$$
DECLARE
	l_oid OID;
BEGIN
  SELECT lo_import(p_path) INTO l_oid;
  SELECT lo_get(l_oid) INTO p_result;
  PERFORM lo_unlink(l_oid);
END;
$$;

CREATE TABLE vardata(oid int, data blob);

-- On server
INSERT INTO vardata(data) SELECT bytea_import('/tmp/vardata.csv');

CREATE TABLE mydata(
	n1    TEXT,
	t2    TEXT,
	t3    TEXT,
	n4    INT,
	n5    INT);
	
--0;P;partyid5;03.002;471112;Herrn;;Max;Mustermann3;;Musterstraße 3;74873;

CREATE OR REPLACE FUNCTION foo() RETURNS VOID
LANGUAGE plpgsql AS 
$$
DECLARE
	line_separator  VARCHAR := '\n';	
	field_delimiter VARCHAR := ';';
	v_source_row    VARCHAR;
	v_column_values VARCHAR;
	v_rowcount      INTEGER := 1;
	v_fieldcount    INTEGER := 1;
	data_array      VARCHAR[][];
	v_maxrows       INTEGER := 0;
	v_maxcols       INTEGER := 0;
BEGIN
	-- calculate how many rows we shall need
    SELECT COUNT(*) + 1 FROM (SELECT regexp_matches(convert_from(data, 'LATIN1'), line_separator, 'g') FROM vardata) INTO v_maxrows;    
	
	FOR v_source_row in SELECT unnest((string_to_array(regexp_replace(convert_from(data, 'LATIN1'), '\r\n', line_separator, 'g'), line_separator))) FROM vardata
	LOOP
		IF v_maxcols = 0
		THEN
			-- calculate how many fields we shall need and initialize the array
			SELECT COUNT(*) + 1 FROM regexp_matches(v_source_row, field_delimiter, 'g') INTO v_maxcols;
			data_array := array_fill(0, ARRAY[v_maxrows, v_maxcols]);
		END IF;
		
		v_fieldcount := 1;
		FOR v_column_values IN SELECT * FROM unnest(string_to_array(v_source_row, field_delimiter))
		LOOP
			data_array[v_rowcount][v_fieldcount] := v_column_values;
			RAISE INFO 'A[%][%]     : %', v_rowcount, v_fieldcount, data_array[v_rowcount][v_fieldcount];
			v_fieldcount := v_fieldcount + 1;
		END LOOP;
		v_rowcount := v_rowcount + 1;
	END LOOP;
		
	FOR i IN 1..v_maxrows 
	LOOP
		EXECUTE 'INSERT INTO mydata VALUES ($1, $2, $3, $4, $5)'
		USING  data_array[i][1], data_array[i][2], data_array[i][3], data_array[i][4], data_array[i][5];
	END LOOP;
END;
$$;

select foo();

select * from mydata;
