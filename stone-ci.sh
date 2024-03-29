#!/usr/bin/env bash

set -e

printLoadingErrorAndExit(){
  echo "::error::Loading failed"
  tail "${GEMSTONE_LOG_DIR}/loading-rowan-projects.log"
  exit 1
}

printTestingErrorAndExit(){
  echo "::error::Some tests has failed"
  cat "${GEMSTONE_LOG_DIR}/running-tests.log"
  exit 1
}

echo "::group::Configuring GemStone services"
# Copy default system config if missing
if [ ! -f "${GEMSTONE_SYS_CONF}/system.conf" ]; then
  cp -p "${GEMSTONE}/data/system.conf" "${GEMSTONE_SYS_CONF}/system.conf"
fi

# Create (empty) stone config if missing
if [ ! -f "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf" ]; then
  touch "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf"
fi
echo "GEM_TEMPOBJ_CACHE_SIZE = 500000KB;" >> "${GEMSTONE_SYS_CONF}/system.conf"
# Workaroung for bug in the native code generator for GS 3.7.0
echo "GEM_NATIVE_CODE_ENABLED = 0;" >> "${GEMSTONE_SYS_CONF}/system.conf"
echo "::endgroup::"

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

echo "::group::Listing active GemStone services"
gslist -cvl
echo "::endgroup::"

echo "::group::Mapping workspace"

echo "Mapping workspace to ${ROWAN_PROJECTS_HOME}/$INPUT_PROJECT_NAME"
ln -s "${GITHUB_WORKSPACE}" "${ROWAN_PROJECTS_HOME}/$INPUT_PROJECT_NAME"
ln -s "${GEMSTONE_GLOBAL_DIR}/StdOutPrinter.gs" "${GITHUB_WORKSPACE}/StdOutPrinter.gs"
ln -s "${GEMSTONE_GLOBAL_DIR}/StdOutTestReporter.gs" "${GITHUB_WORKSPACE}/StdOutTestReporter.gs"
ln -s "${GEMSTONE_GLOBAL_DIR}/Rowan.gs" "${GITHUB_WORKSPACE}/Rowan.gs"
ls -lL "${ROWAN_PROJECTS_HOME}/$INPUT_PROJECT_NAME"
echo "::endgroup::"

echo "::group::Configuring GemStone repository"
/opt/gemstone/configure.sh
echo "::endgroup::"

echo "::group::Loading code"

if [ -z "${INPUT_LOAD_SPEC}" ]; then
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT_NAME}" || printLoadingErrorAndExit
else
  /opt/gemstone/load-rowan-project.sh "${INPUT_PROJECT_NAME}" "${INPUT_LOAD_SPEC}" || printLoadingErrorAndExit
fi

echo "::endgroup::"

if [ "${INPUT_RUN_TESTS}" = "true" ]; then
  echo "::group::Running the test suite"
  /opt/gemstone/run-tests.sh "${INPUT_PROJECT_NAME}" || printTestingErrorAndExit
  cat "${GEMSTONE_LOG_DIR}/running-tests.log"
  echo "::endgroup::"
fi

echo "::group::Stopping services"

stopnetldi

stopstone \
  -i \
  -t "${GS64_STOPSTONE_TIMEOUT_SECONDS}" \
  "$STONE_SERVICE_NAME" \
  DataCurator \
  "${GS64_DATA_CURATOR_PASSWORD}"

echo "::endgroup::"

exit 0
