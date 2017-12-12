#!/bin/bash

INCLUDE_COPY=false
INCLUDE_RAW=false
INCLUDE_MODEL=false
DRY_RUN=false
NO_RECURSE=false
DELETE=false
WORKSPACE_CAT=true

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
  WORKSPACE_CAT=true
else
  echo "Setting cat file sync to ${WORKSPACE_CAT}"
  WORKSPACE_CAT=${WORKSPACE_CAT}
fi

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  -c|--include-copy)
  INCLUDE_COPY=true
  ;;
  -r|--include-raw)
  INCLUDE_RAW=true
  ;;
  -m|--include-model)
  INCLUDE_MODEL=true
  ;;
  -d|--dry-run)
  DRY_RUN=true
  ;;
  -n|--no-recurse)
  NO_RECURSE=true
  ;;
  --skip-cat)
  WORKSPACE_CAT=false
  ;;
  --delete)
  DELETE=true
  ;;
  *)
  USE_DIR=$key
  ;;
esac
shift
done

if [[ -z "${USE_DIR}" ]] && [[ "${NO_RECURSE}" = true ]]; then
  echo 'ERROR: NO_RECURSE must be set to false if you do not specify a subdir'
  exit 1
fi

prefix_command='rsync -avu --exclude *.gz --exclude *.avi --exclude \.in_treatment'

if [[ "${INCLUDE_MODEL}" = false ]]; then
  prefix_command+=" --exclude \"depth_nocable_em.mat\""
fi

if [[ "${INCLUDE_COPY}" = false ]]; then
  prefix_command+=" --exclude \"depth_masked.mat\""
fi

if [[ "${INCLUDE_RAW}" = false ]]; then
  prefix_command+=" --exclude \"depth.dat\" --exclude \"*.gz\""
fi

if [[ "${WORKSPACE_CAT}" = false ]]; then
  prefix_command+=" --exclude \"cat*.mat\""
fi

if [[ "${DRY_RUN}" = true ]]; then
  prefix_command+=" --dry-run"
fi

if [[ "${DELETE}" = true ]]; then
  prefix_command+=" --delete"
fi

if [[ "${NO_RECURSE}" = false ]]; then
  USE_DIR=( `find ${WORKSPACE_LOCAL}/${USE_DIR} -mindepth 1 -maxdepth 1 -type d | cut -c 3- | xargs basename` )
fi

for dir in ${USE_DIR[@]}; do

  base_command="${prefix_command} --stats --progress -e ssh ${USERNAME_ORCHESTRA}@${URL_ORCHESTRA}:${WORKSPACE_ORCHESTRA}/${dir}/ \
    ${WORKSPACE_LOCAL}/${dir}/"

  echo $base_command
  eval $base_command

done
