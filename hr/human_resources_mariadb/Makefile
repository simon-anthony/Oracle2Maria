.SUFFIXES: .mysql .sql

.sql.mysql:
	sqlines -s=oracle -t=mariadb -in=$< -log=$*.log|| true
	@i=$<; mv $${i%.sql}_out.sql $${i%.sql}.mysql; \
	echo "g/^[ 	]*[Pp][Rr][Oo][Mm][Pp][Tt]/s;[Pp][Rr][Oo][Mm][Pp][Tt];--;" > exscript ;\
	echo "g/^[ 	]*[Ss][Ee][Tt]/s;^;-- ;" >> exscript ;\
	echo "g/CONSTRAINT \".*\" NOT NULL/s;CONSTRAINT \".*\" ;;" >> exscript ;\
	echo "g/ORGANIZATION INDEX/s;ORGANIZATION INDEX;;" >> exscript ;\
	echo "g/NOCOMPRESS/s;NOCOMPRESS;;" >> exscript ;\
	echo "1i" >> exscript ;\
	echo "set sql_mode=oracle;" >> exscript ;\
	echo "." >> exscript ;\
	echo "w!" >> exscript ;\
	ex -s $${i%.sql}.mysql < exscript
	@rm -f exscript

SQLFILES := $(shell ls *.sql)
MYSQLFILES = $(SQLFILES:.sql=.mysql)
LOGFILES = $(SQLFILES:.sql=.log)

all: $(MYSQLFILES)

clean:
	rm -f $(MYSQLFILES) $(LOGFILES)

sql:
	./expobj --table > tables.sql
	./expobj --constraint > constraints.sql
	./expobj --index > indexes.sql
	./expobj --procedure > procedures.sql

dummy:
	rm -f *.mysql
	echo "g/,CONSTRAINT.*NOT NULL/s;CONSTRAINT.*;CONSTRAINT;" >> exscript ;\
	echo "g/CONSTRAINT.*NOT NULL/s;$$;);" >> exscript ;\
	echo "g/CONSTRAINT.*NOT NULL/s;\([a-z_]*\)_nn;\1_nn CHECK (\1 IS;" >> exscript ;\
	echo "g/ORGANIZATION INDEX/s;ORGANIZATION INDEX;;" >> exscript ;\
