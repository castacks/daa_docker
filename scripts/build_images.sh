#!/bin/bash

# Input arguments.
DOCKERHUB_ACCOUNT=$1
NGC_VERSION=$2
HOME_COPY=$3

ECHO_PREFIX=">>>"

# Detect the system architecture.
UNAME=$(uname -m)
if [ "$UNAME" == "x86_64" ]; then
    ARCH="x86"
elif [ "$UNAME" == "aarch64" ]; then
    ARCH="arm"
else
    echo "Unsupported architecture: $UNAME"
    exit 1
fi

if [ "${ARCH}" == "x86" ]; then
    echo "${ECHO_PREFIX} Build for ${ARCH}. "
    ./build_x86_images.sh ${DOCKERHUB_ACCOUNT} ${NGC_VERSION} ${HOME_COPY}
else
    # Duplicate line for debug purpose.
    echo "${ECHO_PREFIX} Build for ${ARCH}. "
    ./build_arm_images.sh ${DOCKERHUB_ACCOUNT} ${NGC_VERSION} ${HOME_COPY}
fi

echo ""
echo "${ECHO_PREFIX} $0 done. "
