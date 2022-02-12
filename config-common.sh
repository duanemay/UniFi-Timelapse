#!/bin/false
# shellcheck shell=bash
# shellcheck disable=SC2034 ## This file is sourced by multiple scripts

SNAP_BASE="${SCRIPT_DIR}"
TIMELAPSE_DIR="${SNAP_BASE}/Timelapse"

DATETIME_EXT=$(date '+%Y-%m-%dT%H:%M:%S')
DATE_EXT=$(date '+%Y-%m-%d')
YESTERDAY_EXT=$(TZ=GMT+30 date +%Y-%m-%d)

# add here the framerate of the video
FRAMERATE=20

declare -A CAMS
# shellcheck source=./config-camera.sh
. "${SCRIPT_DIR}/config-camera.sh"

VERBOSE=1
log() {
  if [[ -n "${VERBOSE}" ]]; then echo "$@"; fi
}

logerr() {
  echo "$@" 1>&2
}

createDir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

cleanupDir() {
  local TEMP_DIR=${1:?directory to cleanup not specified}
  if [ -n "${TEMP_DIR}" ] && [ -d "${TEMP_DIR}" ]; then
    echo "Cleaning up temporary files... ${TEMP_DIR}"
    rm -rf "${TEMP_DIR}"
  fi
}
