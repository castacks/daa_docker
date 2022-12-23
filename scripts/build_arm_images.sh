#!/bin/bash

# Input arguments.
DOCKERHUB_ACCOUNT=$1
NGC_VERSION=$2
HOME_COPY=$3

# Constants.
PLATFORM=arm
ECHO_PREFIX=">>>"

echo "============================================================"
echo "Build the images for the ${PLATFORM} platform. "
echo "============================================================"
echo ""

# Build the images in order.
echo "${ECHO_PREFIX} Building 01_base..."
echo ""

./build_docker_image.sh \
    desktop_and_jetson/01_base.dockerfile \
    ${DOCKERHUB_ACCOUNT} \
    ${PLATFORM} \
    ${NGC_VERSION} \
    py3 \
    01_base \
    -b nvcr.io/nvidia/pytorch:${NGC_VERSION}-py3

echo ""
echo "${ECHO_PREFIX} Building 02_scikit..."
echo ""

./build_docker_image.sh \
    desktop_and_jetson/02_scikit.dockerfile \
    ${DOCKERHUB_ACCOUNT} \
    ${PLATFORM} \
    ${NGC_VERSION} \
    01_base \
    02_scikit

echo ""
echo "${ECHO_PREFIX} Building 03_fiftyone..."
echo ""

./build_docker_image.sh \
    desktop_and_jetson/03_fiftyone.dockerfile \
    ${DOCKERHUB_ACCOUNT} \
    ${PLATFORM} \
    ${NGC_VERSION} \
    02_scikit \
    03_fiftyone

echo ""
echo "${ECHO_PREFIX} Building 99_local..."
echo ""

./add_user_2_image.sh \
    ${DOCKERHUB_ACCOUNT}/ngc_${PLATFORM}_daa:${NGC_VERSION}_03_fiftyone \
    ${DOCKERHUB_ACCOUNT}/ngc_${PLATFORM}_daa:${NGC_VERSION}_99_local \
    ${HOME_COPY}

# List all the images that have been built.
echo ""
echo "The images that built for ${PLATFORM} platform with NGC version ${NGC_VERSION}: "
echo "=========="
docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${PLATFORM}*:${NGC_VERSION}*"

echo ""
echo "${ECHO_PREFIX} $0 done. "