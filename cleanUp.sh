#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
export SCRIPT_DIR
[ ${DEBUG} ] && echo "SCRIPT_DIR: ${SCRIPT_DIR}"

# shellcheck source=./config-common.sh
. "${SCRIPT_DIR}/config-common.sh"

cleanupFiles() {
  local NAME=${1:?Name not specified}
  local cameraDir="$SNAP_BASE/${NAME}"

  ## Delete Dirs after 22 days
  echo "=-=-==-=-=-=-=-=-=- ${NAME} Old Directories Before -=-=-=-=-=-=-=-=-=-="
  find "${cameraDir}" -type d -ctime +22 -print
  find "${cameraDir}" -type d -ctime +22 -exec /bin/rm -r {} \;
  echo
  echo "=-=-==-=-=-=-=-=-=- ${NAME} Old Directories After -=-=-=-=-=-=-=-=-=-="
  find "${cameraDir}" -type d -ctime +22 -print

  ## Delete Pictures after 15 days
  echo "=-=-==-=-=-=-=-=-=- ${NAME} Pictures Before -=-=-=-=-=-=-=-=-=-="
  find "${cameraDir}" -type f -ctime +15 -print
  find "${cameraDir}" -type f -ctime +15 -exec /bin/rm -r {} \;

  echo "=-=-==-=-=-=-=-=-=- ${NAME} Pictures After -=-=-=-=-=-=-=-=-=-="
  find "${cameraDir}" -type f -ctime +15 -print
}

cleanupTimelapse() {
  ## Delete Videos after 22 days
  echo "=-=-==-=-=-=-=-=-=- Videos Before -=-=-=-=-=-=-=-=-=-="
  find "${TIMELAPSE_DIR}" -type f -name "*.mp4" -ctime +22 -print
  find "${TIMELAPSE_DIR}" -type f -name "*.mp4" -ctime +22 -exec /bin/rm -r {} \;

  echo "=-=-==-=-=-=-=-=-=- Videos After -=-=-=-=-=-=-=-=-=-="
  find "${TIMELAPSE_DIR}" -type f -name "*.mp4" -ctime +22 -print
}

df -h .
for i in "${!CAMS[@]}"; do
  cleanupFiles "${i}"
done
cleanupTimelapse
df -h .
