#!/usr/bin/env bash

set -e

echo "::group::Starting GemStone services"

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

echo "::endgroup::"

echo "Listing GemStone services"
gslist -cvl

echo "Mapping workspace to ${ROWAN_PROJECTS_HOME}/$INPUT_PROJECT_NAME"
ln -s "${GITHUB_WORKSPACE}" "${ROWAN_PROJECTS_HOME}/$INPUT_PROJECT_NAME"

echo "Loading the code in the image"

if [ -z "${INPUT_LOAD_SPEC}" ]; then
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT_NAME}"
else
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT_NAME}" "${INPUT_LOAD_SPEC}"
fi

if [ "${INPUT_RUN_TESTS}" = "true" ]; then
  echo "Running the test suite"
  /opt/gemstone/run-tests.sh "${INPUT_PROJECT_NAME}"
fi

echo "Stopping services"

stopnetldi

stopstone \
  -i \
  -t "${STOPSTONE_TIMEOUT_SECONDS}" \
  "$STONE_SERVICE_NAME" \
  DataCurator \
  "${DATA_CURATOR_PASSWORD}"


exit 0
