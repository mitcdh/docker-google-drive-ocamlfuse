#!/bin/sh

DRIVE_PATH=${DRIVE_PATH:-/mnt/gdrive}

PUID=${PUID:-0}
PGID=${PGID:-0}

# Create a group for our gid if required
if [ -z "$(getent group gdfuser)" ]; then
	echo "creating gdfuser group for gid ${PGID}"
	groupadd --gid ${PGID} --non-unique gdfuser >/dev/null 2>&1
fi

# Create a user for our uid if required
if [ -z "$(getent passwd gdfuser)" ]; then
	echo "creating gdfuser group for uid ${PUID}"
	useradd --gid ${PGID} --non-unique --comment "Google Drive Fuser" \
	 --home-dir "/config" --create-home \
	 --uid ${PUID} gdfuser >/dev/null 2>&1

	echo "taking ownership of /config for gdfuser"
	chown ${PUID}:${PGID} /config
fi

# check if our config exists already
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
		# google-drive-ocamlfuse doesn't clear stdin so pipe works
		echo "initializing google-drive-ocamlfuse..."
		su gdfuser -l -c  "echo \"${VERIFICATION_CODE}\" | \
		 google-drive-ocamlfuse -headless \
		 -id \"${CLIENT_ID}.apps.googleusercontent.com\" \
		 -secret \"${CLIENT_SECRET}\""

		# set teamdrive config"
		if [ -n "${TEAM_DRIVE_ID}" ];then
			sed -i "s/team_drive_id=/team_drive_id=${TEAM_DRIVE_ID}/g" /config/.gdfuse/default/config
		fi
	fi
fi

# prepend additional mount options with a comma
if [ -n "${MOUNT_OPTS}" ]; then
	MOUNT_OPTS=",${MOUNT_OPTS}"
fi

# mount as the gdfuser user
echo "mounting at ${DRIVE_PATH}"
exec su gdfuser -l -c "google-drive-ocamlfuse \"${DRIVE_PATH}\"\
 -f -o uid=${PUID},gid=${PGID}${MOUNT_OPTS}"
