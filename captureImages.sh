#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
export SCRIPT_DIR
[ ${DEBUG} ] && echo "SCRIPT_DIR: ${SCRIPT_DIR}"

# shellcheck source=./config-common.sh
. "${SCRIPT_DIR}/config-common.sh"

captureImage() {
  local NAME=${1:?Name not specified}
  local URL=${2:?URL not specified}

  local snapDir="${SNAP_BASE}/${NAME}/${DATE_EXT}"
  createDir "${snapDir}"

  local snapFile="${snapDir}/${DATETIME_EXT}.jpg"
  log savingSnap "${URL}" to "${snapFile}"

  wget --quiet -O "${snapFile}" "${URL}"
}

for i in "${!CAMS[@]}"; do
  captureImage "${i}" "${CAMS[${i}]}"
done
