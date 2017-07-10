#!/bin/bash

DRY_RUN=false

if [ -z "$WORKSPACE_LOCAL" ]; then
	echo 'ERROR: you must have $WORKSPACE_LOCAL set in your environment'
	exit 1
fi

if [ -z "$USERNAME_ORCHESTRA" ]; then
	echo 'ERROR: you must have $USERNAME_ORCHESTRA set in your environment'
	exit 1
fi

if [ -z "$WORKSPACE_ORCHESTRA" ]; then
	echo 'ERROR: you must have $WORKSPACE_ORCHESTRA set in your environment'
	exit 1
fi

while [[ $# -gt 0 ]]
do
key="$1"
echo $key
case $key in
		-d|--dry-run)
		DRY_RUN=true
		;;
		*)
		USE_DIR=$key
    ;;
esac
shift
done

base_command="rsync -avu"

if [[ "${DRY_RUN}" = true ]]; then
	base_command+=" --dry-run"
fi

base_command+=" --stats --progress ${WORKSPACE_LOCAL}/${USE_DIR}/ -e ssh ${USERNAME_ORCHESTRA}@${URL_ORCHESTRA}:${WORKSPACE_ORCHESTRA}/${USE_DIR}/"

echo $base_command
eval $base_command
