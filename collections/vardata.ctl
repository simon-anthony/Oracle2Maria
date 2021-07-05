LOAD DATA
INFILE vardata.dat
TRUNCATE
    INTO TABLE vardata
    FIELDS TERMINATED BY ','
    TRAILING NULLCOLS
    (
        cid			CHAR(1),
		ext_fname	FILLER CHAR(40),
		"CDATA"		LOBFILE(ext_fname) TERMINATED BY EOF
	)
