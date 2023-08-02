#!/usr/bin/env bash

set -e

echo "Starting GemStone services"

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

echo "Listing GemStone services"
gslist -cvl

echo "Mapping workspace to ${ROWAN_PROJECTS_HOME}/${INPUT_PROJECT-NAME}"
ln -s "${GITHUB_WORKSPACE}" "${ROWAN_PROJECTS_HOME}/${INPUT_PROJECT-NAME}"

echo "Loading the code in the image"

if [ -z "${INPUT_LOAD-SPEC}" ]; then
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT-NAME}"
else
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT-NAME}" "${INPUT_LOAD-SPEC}"
fi

if [ "${INPUT_RUN-TESTS}" == "true" ]; then
  echo "Running the test suite"
  /opt/gemstone/run-tests.sh "${INPUT_PROJECT-NAME}"
fi

exit 0
