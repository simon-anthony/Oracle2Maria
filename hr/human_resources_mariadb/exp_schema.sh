#!/bin/sh -

sqlplus -s <<-!
	hr/hr7839
	set pagesize 0 tab off newp none emb on heading off feedback off verify off echo off trimspool on
	set long 2000000000 linesize 9999

	column line for a9999

	BEGIN
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', TRUE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'TABLESPACE', FALSE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', TRUE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', FALSE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'FORCE', FALSE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', true);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'EMIT_SCHEMA', FALSE);
	END;
	/

	spool schema.sql

	SELECT dbms_metadata.get_ddl(object_type, object_name, user) line
	FROM user_objects
	WHERE object_type IN (
		'TABLE', 'VIEW', 'SEQUENCE', 'FUNCTION', 'PACKAGE', 'PACKAGE_BODY', 'PROCEDURE', 'INDEX', 'SYNONYM', 'TRIGGER', 'TYPE')
	ORDER BY DECODE(object_type,
					'TABLE', 1,
					'VIEW', 2,
					'INDEX', 3,
					'TRIGGER', 4,
					'PACKAGE', 5,
					'PACKAGE BODY', 6,
									7), object_type;
	spool off
!
