#!/bin/sh -

# https://customers.mariadb.com/migration-portal/help

export TWO_TASK=ORCL
expdp "system/Naxy7839" SCHEMAS=HR CONTENT=METADATA_ONLY EXCLUDE=STATISTICS DUMPFILE=hr.dmp

