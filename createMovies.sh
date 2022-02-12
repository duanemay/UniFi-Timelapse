#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
export SCRIPT_DIR
[ "${DEBUG}" ] && echo "SCRIPT_DIR: ${SCRIPT_DIR}"

# shellcheck source=./config-common.sh
. "${SCRIPT_DIR}/config-common.sh"

createMovie() {
  local NAME=${1:?Name not specified}
  local WHEN=${2:?When not specified}
  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  local cameraDir="$SNAP_BASE/${NAME}"
  local filePath
  local TIMELAPSE_FILE

  if [ "${WHEN}" = "today" ]; then
    log "Creating video of ${NAME} from ${WHEN}'s images, in ${TEMP_DIR}"
    filePath="${cameraDir}/${DATE_EXT}"
    TIMELAPSE_FILE="${TIMELAPSE_DIR}/${NAME} - ${DATE_EXT}.mp4"
  elif [ "${WHEN}" = "yesterday" ]; then
    log "Creating video of ${NAME} from ${WHEN}'s images, in ${TEMP_DIR}"
    filePath="${cameraDir}/${YESTERDAY_EXT}"
    TIMELAPSE_FILE="${TIMELAPSE_DIR}/${NAME} - ${YESTERDAY_EXT}.mp4"
  elif [ -d "${cameraDir}/${WHEN}" ]; then
    log "Creating video of ${NAME} from ${WHEN}'s images, in ${TEMP_DIR}"
    filePath="${cameraDir}/${WHEN}"
    TIMELAPSE_FILE="${TIMELAPSE_DIR}/${NAME} - ${WHEN}.mp4"
  else
    log "Creating video of ${NAME} from all images, in ${TEMP_DIR}"
    filePath="${cameraDir}"
    TIMELAPSE_FILE="${TIMELAPSE_DIR}/${NAME} - All-to-${DATE_EXT}.mp4"
  fi

  # need to chance current dir so links work over network mounts
  cd "${TEMP_DIR}" || exit
  x=1
  find "${filePath}" -type f -name '*.jpg' -print0 | sort | while IFS= read -r -d '' file; do
    local counter
    counter=$(printf %06d $x)
    [ "$DEBUG" ] && echo "$counter.jpg" ← "${file}" || echo -n "."
    cp "${file}" "$counter.jpg"
    export x=$((x + 1))
  done

  if [ -f "*.jpg" ]; then
    logerr "ERROR: no files found"
    cleanupDir "${TEMP_DIR}"
    exit 2
  fi

  echo
  createDir "${TIMELAPSE_DIR}"
  # create with framerate supplied, gives MP4
  if [ -f "${SNAP_BASE}/audio.mp3" ]; then
    echo Generating "${TIMELAPSE_FILE}" with music
    nice -n 20 ffmpeg -threads 1 -fflags discardcorrupt -r "${FRAMERATE}" -start_number 1 -i "${TEMP_DIR}/"%06d.jpg -stream_loop -1 -i "${SNAP_BASE}/audio.mp3" -map 0:v -map 1:a -map_channel 1.0.1 -map_channel 1.0.0 -c:v libx264 -s hd1080 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p "${TIMELAPSE_FILE}" -hide_banner -loglevel panic -stats

  else
    echo Generating "${TIMELAPSE_FILE}"
    nice -n 20 ffmpeg -threads 1 -r "${FRAMERATE}" -start_number 1 -i "${TEMP_DIR}/"%06d.jpg -c:v libx264 -s hd1080 -preset slow -crf 18 -c:a copy -pix_fmt yuv420p "${TIMELAPSE_FILE}" -hide_banner -loglevel panic -stats
  fi

  log "Created ${TIMELAPSE_FILE}"
  echo
  
  # Clean up temporary files
  cleanupDir "${TEMP_DIR}"
}

WHEN=${1:-yesterday}
for i in "${!CAMS[@]}"; do
  createMovie "${i}" "${WHEN}"
done
