#!/bin/bash

QUARANTINE_DIR=/opt/clamav/quarantine

while [ "zPONG" != "z$( echo PING | nc localhost 3310 )" ];
do
	sleep 1;
done;

if [ ! -d ${QUARANTINE_DIR} ]; then
	mkdir -p ${QUARANTINE_DIR}
fi

/usr/local/sbin/clamonacc --fdpass --move=${QUARANTINE_DIR}
