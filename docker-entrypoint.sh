#!/bin/sh

DRIVE_PATH=/mnt/gdrive

if [ -e "~/.gdfuse/default/config" ]; then
	echo "existing google-drive-ocamlfuse config found"
else
	if [ -z "${CLIENT_ID}" ]; then
	    echo "no CLIENT_ID found -> EXIT"
	    exit 1
	elif [ -z "${CLIENT_SECRET}" ]; then
	    echo "no CLIENT_SECRET found -> EXIT"
	    exit 1
	elif [ -z "$VERIFICATION_CODE" ]; then
	    echo "no VERIFICATION_CODE found -> EXIT"
	    exit 1
	else
		echo "initilising google-drive-ocamlfuse..."
		echo "${VERIFICATION_CODE}" | \
			google-drive-ocamlfuse -headless -id "${CLIENT_ID}.apps.googleusercontent.com" -secret "${CLIENT_SECRET}"
	fi
fi

echo "mounting at ${DRIVE_PATH}"
google-drive-ocamlfuse "${DRIVE_PATH}"
tail -f /dev/null & wait