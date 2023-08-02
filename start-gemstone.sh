#!/usr/bin/env bash

set -e

# Start GemStone services
# shellcheck disable=SC2086
startnetldi \
  -g \
  -a "${GS_USER}" \
  -n \
  -P "${NETLDI_PORT}" \
  -l "${GEMSTONE_LOG_DIR}/${NETLDI_SERVICE_NAME}.log" \
  ${NETLDI_ARGS:-} \
  "${NETLDI_SERVICE_NAME}"

# shellcheck disable=SC2086
startstone \
  -e "${GEMSTONE_EXE_CONF}" \
  -z "${GEMSTONE_SYS_CONF}" \
  -l "${GEMSTONE_LOG_DIR}/${STONE_SERVICE_NAME}.log" \
  ${STONE_ARGS:-} \
  ${STONE_SERVICE_NAME}

# list GemStone servers
gslist -cvl

# Load the code
export GS64_CI_PROJECT_NAME="${INPUT_PROJECT_NAME}"

if [ -n "${INPUT_LOAD_SPEC}" ]; then
  export GS64_CI_SPEC="${INPUT_LOAD_SPEC}"
fi

/opt/gemstone/load-rowan-project.sh 

# Run the test suite if configured

if [ "${INPUT_RUN-TESTS}" == "true" ]; then
  # Run the test suite
  /opt/gemstone/run-tests.sh "${INPUT_PROJECT_NAME}"
fi

# Stop GemStone services

stopnetldi

stopstone \
  -i \
  -t "${STOPSTONE_TIMEOUT_SECONDS}" \
  "$STONE_SERVICE_NAME" \
  DataCurator \
  "${DATA_CURATOR_PASSWORD}"
