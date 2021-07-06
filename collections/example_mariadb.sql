-- vim: syntax=mysql:ts=4:sw=4:
SET serveroutput ON

CREATE TABLE vardata(cid INT, cdata CLOB);

-- Data loaded in the following fashion:
-- vardata.ctl
-- ===========
-- LOAD DATA
-- INFILE vardata.dat
-- TRUNCATE
--    INTO TABLE vardata
--    FIELDS TERMINATED BY ','
--    TRAILING NULLCOLS
--    (
--        cid         CHAR(1),
--        ext_fname   FILLER CHAR(40),
--        "CDATA"     LOBFILE(ext_fname) TERMINATED BY EOF
--    )
-- vardata.dat
-- ===========
-- 1,vardata.csv

-- vardata.csv
-- ===========
-- contains the original CSV file

SELECT * FROM vardata;
SELECT cdata FROM vardata;

DROP TABLE vardata;

SELECT regexp_count(cdata, '\n', 1, 'm')  FROM vardata ; 
SELECT regexp_count(REPLACE(cdata, CHR(13)), '$', 1, 'm')  FROM vardata ; 

CREATE TABLE mydata(
        n1    VARCHAR2(256),
        t2    VARCHAR2(256),
        t3    VARCHAR2(256),
        n4    INT,
        n5    INT);

CREATE OR REPLACE
PACKAGE mypkg
AS
    line_separator  VARCHAR2(2) := '\n';	
    field_delimiter VARCHAR2(1) := ';';

    PROCEDURE fill;
END mypkg;
/

CREATE OR REPLACE 
PACKAGE BODY mypkg
AS
    TYPE nt IS TABLE OF VARCHAR2(256);
    v_nt   nt;
    TYPE ntt IS TABLE OF nt;
    v_ntt  ntt;
    
    TYPE MyDataRow IS TABLE OF mydata%ROWTYPE;
    --rowlist MyDataRow := MyDataRow();
    rowlist MyDataRow;

    
    PROCEDURE fill
    AS
        l_maxrows       INTEGER := 0;
        l_maxcols       INTEGER := 0;
        l_row           INTEGER := 1;
        l_col           INTEGER := 1;
        l_field         VARCHAR2(256);
        l_offset        INTEGER := 1;
    BEGIN

        -- Calculate spreadsheet dimensions
        SELECT regexp_count(cdata, '$', 1, 'm') INTO l_maxrows FROM vardata; 
        -- THere is a trailing field after the last ';' so + 1:
        SELECT regexp_count(regexp_substr(cdata, '^.*$', 1, 1, 'm'), ';') + 1 INTO l_maxcols FROM vardata;
        dbms_output.put_line('Rows: '|| l_maxrows || ' Cols: '|| l_maxcols);
        
        v_ntt := ntt(v_nt);
        
        WHILE l_row <= l_maxrows LOOP 
            v_nt := nt(l_maxcols);
            
            WHILE l_col <= l_maxcols LOOP
                SELECT RTRIM(regexp_substr(cdata, '[^;]*;?', l_offset, l_col, 'm'), ';') INTO l_field FROM vardata;
                
                -- Check only the "last" field in in each "row" for CR/LF as there are limits (32767) on string manipulation in LOBs
                IF l_col = l_maxcols
                THEN
                    l_field := SUBSTR(l_field, 1, INSTR(l_field, CHR(10), -1)-2);
                END IF;
                
                dbms_output.put_line('Row '||l_row||' Field '||l_col||' is: '||l_field);

                v_nt.EXTEND;
                v_nt(l_col) := l_field;
                l_col := l_col + 1;
            END LOOP;
            v_ntt.EXTEND;
            v_ntt(l_row) := v_nt;
            l_row := l_row + 1;
            l_col := 1;

            -- Calculate new offset
            SELECT regexp_instr(cdata, '$', l_offset, 1, 1, 'm') +1 INTO l_offset FROM vardata;

        END LOOP;
 
        FOR i IN v_ntt.FIRST..v_ntt.LAST-1 LOOP
            FOR j IN v_nt.FIRST..v_nt.LAST-1 LOOP
                dbms_output.put_line('* Row '||i||' Field '||j||' is: '||v_ntt(i)(j));
            END LOOP;
        END LOOP;
        
        -- Example Bulk insert
        rowlist := MyDataRow();
        
        -- Need to use a table to overcome 1 subscript limit on bulk  binds     
        FOR i IN v_ntt.FIRST..v_ntt.LAST-1 LOOP
            rowlist.EXTEND;          
            rowlist(i).n1 := v_ntt(i)(1);
            rowlist(i).t2 := v_ntt(i)(2);
            rowlist(i).t3 := v_ntt(i)(3);
            rowlist(i).n4 := v_ntt(i)(4);
            rowlist(i).n5 := v_ntt(i)(5);
            dbms_output.put_line('* Record '||i||' is: n1: '|| rowlist(i).n1 ||', t2: '|| rowlist(i).t2 ||'t3: '|| rowlist(i).t3 ||', n4: '|| rowlist(i).n4 ||', n5: '|| rowlist(i).n5);
        END LOOP;
            
        FORALL i IN rowlist.FIRST..rowlist.LAST
          EXECUTE IMMEDIATE 'INSERT INTO mydata (n1, t2, t3, n4, n5) VALUES (:1, :2, :3, :4, :5)'
            USING rowlist(i).n1, rowlist(i).t2, rowlist(i).t3, rowlist(i).n4, rowlist(i).n5;
    END;
END mypkg;
/

BEGIN
    mypkg.fill;
END;
/
    
SELECT COUNT(*) FROM mydata;
SELECT * from mydata;
DELETE FROM mydata;
commit;
