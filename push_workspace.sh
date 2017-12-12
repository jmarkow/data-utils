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

if [ -z "$WORKSPACE_CAT" ]; then
  SKIP_CAT=false
else
  echo "Setting cat file skip to ${WORKSPACE_CAT}"
  SKIP_CAT=${WORKSPACE_CAT}
fi

while [[ $# -gt 0 ]]
do
key="$1"
echo $key
case $key in
  -d|--dry-run)
  DRY_RUN=true
  ;;
  --skip-cat)
  SKIP_CAT=true
  ;;
  *)
  USE_DIR=$key
  ;;
esac
shift
done

prefix_command='rsync -avu --exclude \.in_treatment'

if [[ "${SKIP_CAT}" = true ]]; then
  prefix_command+=" --exclude \"cat*.mat\""
fi

if [[ "${DRY_RUN}" = true ]]; then
  prefix_command+=" --dry-run"
fi

prefix_command+=" --stats --progress ${WORKSPACE_LOCAL}/${USE_DIR}/ -e ssh ${USERNAME_ORCHESTRA}@${URL_ORCHESTRA}:${WORKSPACE_ORCHESTRA}/${USE_DIR}/"

echo $prefix_command
eval $prefix_command
