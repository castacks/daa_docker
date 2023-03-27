#!/bin/bash

DOCKERHUB_ACCOUNT=$1
NGC_VERSION=$2

ECHO_PREFIX=">>>"

# Copy the WORKSPACE.jp50 file.
cp ../toolchains/jp_workspaces/WORKSPACE.jp50 ./

docker build \
    -t ${DOCKERHUB_ACCOUNT}/ngc_l4t_daa/${NGC_VERSION}_01_torch_tensorrt \
    -f docker/Dockerfile.l4t \
    --build-arg BASE=${NGC_VERSION}

docker tag \
    ${DOCKERHUB_ACCOUNT}/ngc_l4t_daa/${NGC_VERSION}_01_torch_tensorrt \
    ${DOCKERHUB_ACCOUNT}/ngc_l4t_daa/${NGC_VERSION}_99_latest

# List all the images that have been built.
echo ""
echo "${ECHO_PREFIX} The images that built from with NGC L4T ${NGC_VERSION}: "
echo "=========="
docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*l4t_daa:${NGC_VERSION}*"

echo "${ECHO_PREFIX} $0 done. "
