#!/usr/bin/env bash

set -x

PEGLEG_IMAGE=${PEGLEG_IMAGE:-quay.io/airshipit/pegleg:master}

echo
echo "== NOTE: Workspace $WORKSPACE  is available as /workspace in container context =="
echo

docker run --rm -it \
    --net=none \
    --workdir="/site" \
    -v "${WORKSPACE}:/site" \
    -v "${AIRSHIP_TREASUREMAP}:/global" \
    "${PEGLEG_IMAGE}" \
        pegleg "${@}"
