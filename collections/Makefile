# $Header$
.SUFFIXES: .log .dat

USER = simonanthony@ORCL
PASS = Naxy7839
USER = 
PASS = @ORCL

.dat.log:
	sqlldr $(USER)/$(PASS) errors=1000 control=$*.ctl data=$*.dat log=$*.log

load: vardata.log

clean:
	rm -f *.log *.bad

install: clean
	sqlplus $(USER)/$(PASS) @drop_tables

