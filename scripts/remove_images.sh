#!/bin/bash

# Input arguments.
DOCKERHUB_ACCOUNT=$1
PLATFORM=$2
NGC_VERSION=$3

docker rmi $(docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${PLATFORM}*:${NGC_VERSION}*" -q)
