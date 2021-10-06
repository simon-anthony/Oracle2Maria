.SUFFIXES: .mysql .sql

# MDEV-10577 and MDEV-11210 - RETURN from function cannot yet include %TYPE
.sql.mysql:
	sqlines -s=oracle -t=mariadb_ora -in=$< -log=$*.log || true
	@i=$<; mv $${i%.sql}_out.sql $${i%.sql}.mysql; \
	echo "g/^[ 	]*[Pp][Rr][Oo][Mm][Pp][Tt]/s;[Pp][Rr][Oo][Mm][Pp][Tt];--;" > exscript ;\
	echo "g/^[ 	]*[Ss][Ee][Tt]/s;^;-- ;" >> exscript ;\
	echo "g/CONSTRAINT \".*\" NOT NULL/s;CONSTRAINT \".*\" ;;" >> exscript ;\
	echo "g/ORGANIZATION INDEX/s;ORGANIZATION INDEX;;" >> exscript ;\
	echo "g/NOCOMPRESS/s;NOCOMPRESS;;" >> exscript ;\
	echo "g%DELIMITER //%s;//;\$$\$$" >> exscript ;\
	echo "g/^  *[A-Za-z_]\{1,\};/d" >> exscript ;\
	echo "g%^/$$%s;/;\$$\$$;" >> exscript ;\
	if [ "$*" = "packages" ] ;\
	then \
		echo "g%DELIMITER ;%d" >> exscript ;\
		echo "g%^  //%d" >> exscript ;\
		echo "g/RETURN employees.salary%TYPE/s;RETURN.*;RETURN decimal\;;" >> exscript ;\
		echo "g/employees\..*%TYPE/s;employees;hr.&;" >> exscript ;\
	fi ;\
	if [ "$*" = "packages" -o "$*" = "procedures" -o "$*" = "functions" ] ;\
	then \
		echo "1i" >> exscript ;\
		echo "-- vim: syntax=sqloracle:ts=4:sw=4:" >> exscript ;\
		echo "set sql_mode=ORACLE;" >> exscript ;\
		echo "." >> exscript ;\
	fi ;\
	echo "w!" >> exscript ;\
	ex -s $${i%.sql}.mysql < exscript
	@rm -f exscript

SQLFILES := $(shell ls *.sql)
#SQLFILES = constraints.sql functions.sql indexes.sql packages.sql procedures.sql tables.sql
#OBJECTS = constraints functions indexes packages procedures tables
#SQLFILES = $(OBJECTS:=.sql)
MYSQLFILES = $(SQLFILES:.sql=.mysql)
LOGFILES = $(SQLFILES:.sql=.log)

all: $(MYSQLFILES)

clean:
	rm -f $(MYSQLFILES) $(LOGFILES)

sql: tables constraints indexes procedures functions packages sequences

tables:
	./get_ddl --table > tables.sql

constraints:
	./get_ddl --constraint > constraints.sql

indexes:
	./get_ddl --index > indexes.sql

procedures:
	./get_ddl --procedure > procedures.sql

functions:
	./get_ddl --function > functions.sql

packages:
	./get_ddl --package > packages.sql

sequences:
	./get_ddl --sequence > sequences.sql

drop: 
	cp ../human_resources/hr_drop.sql drop.sql
	make drop.mysql
	

	


dummy:
	rm -f *.mysql
	echo "g/,CONSTRAINT.*NOT NULL/s;CONSTRAINT.*;CONSTRAINT;" >> exscript ;\
	echo "g/CONSTRAINT.*NOT NULL/s;$$;);" >> exscript ;\
	echo "g/CONSTRAINT.*NOT NULL/s;\([a-z_]*\)_nn;\1_nn CHECK (\1 IS;" >> exscript ;\
	echo "g/ORGANIZATION INDEX/s;ORGANIZATION INDEX;;" >> exscript ;\
	echo "g/^  *[A-Za-z_]\{1,\};/d" >> exscript ;\
	echo "g//^\/\$$/d" >> exscript ;\
	echo "1i" >> exscript ;\
	echo "set sql_mode=oracle;" >> exscript ;\
	echo "." >> exscript ;\
