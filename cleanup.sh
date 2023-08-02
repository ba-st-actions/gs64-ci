#!/usr/bin/env bash

stopnetldi

stopstone \
  -i \
  -t "${STOPSTONE_TIMEOUT_SECONDS}" \
  "$STONE_SERVICE_NAME" \
  DataCurator \
  "${DATA_CURATOR_PASSWORD}"
