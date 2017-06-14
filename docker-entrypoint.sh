#!/bin/sh

DRIVE_PATH=/mnt/gdrive

PUID=${PUID:-0}
PGID=${PGID:-0}

if [ ! $(getent group gdfuser) ]; then
          echo "creating gdfuser group for gid ${PGID}"
          groupadd --gid ${PGID} --non-unique gdfuser >/dev/null 2>&1
fi

if [ ! $(getent passwd gdfuser) ]; then
          echo "creating gdfuser group for uid ${PUID}"
          useradd --gid ${PGID} --non-unique --comment "Google Drive Fuser" \
           --home-dir "/config" --create-home \
           --uid ${PUID} gdfuser >/dev/null 2>&1

          echo "taking ownership of /config for gdfuser"
          chown ${PUID}:${PGID} /config
fi

if [ -e "/config/.gdfuse/default/config" ]; then
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
                su gdfuser -l -c  "echo \"${VERIFICATION_CODE}\" | \
                 google-drive-ocamlfuse -headless \
                 -id \"${CLIENT_ID}.apps.googleusercontent.com\" \
                 -secret \"${CLIENT_SECRET}\""
        fi
fi

echo "mounting at ${DRIVE_PATH}"
su gdfuser -l -c "google-drive-ocamlfuse \"${DRIVE_PATH}\"\
 -o uid=${PUID},gid=${PGID}"

tail -f /dev/null & wait
