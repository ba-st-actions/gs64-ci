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

ln -s "${GITHUB_WORKSPACE}" "${ROWAN_PROJECTS_HOME}/${GS64_CI_PROJECT_NAME}"

if [ -z "${INPUT_LOAD_SPEC}" ]; then
  GS64_CI_PROJECT_NAME="${INPUT_PROJECT_NAME}" /opt/gemstone/load-rowan-project.sh 
else
  GS64_CI_SPEC="${INPUT_LOAD_SPEC}" GS64_CI_PROJECT_NAME="${INPUT_PROJECT_NAME}" /opt/gemstone/load-rowan-project.sh 
fi

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
