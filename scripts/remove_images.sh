#!/bin/bash

# Input arguments.
DOCKERHUB_ACCOUNT=$1
NGC_VERSION=$2

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

shift 3
while getopts ":c" flag
do
    case "${flag}" in
        c) # Confirm to remove.
            echo "Removing..."
            docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${ARCH}*:${NGC_VERSION}*"
            docker rmi $(docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${ARCH}*:${NGC_VERSION}*" -q)            
            exit;;
    esac
done

echo "===================================================="
echo "Dry run by default. Use -c to confirm the deletion. "
echo "===================================================="
echo ""

echo "The following images will be removed once -c option is used."
docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${ARCH}*:${NGC_VERSION}*"