#!/bin/bash

# Input arguments.
DOCKERHUB_ACCOUNT=$1
PLATFORM=$2
NGC_VERSION=$3

shift 3
while getopts ":c" flag
do
    case "${flag}" in
        c) # Confirm to remove.
            echo "Removing..."
            docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${PLATFORM}*:${NGC_VERSION}*"
            docker rmi $(docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${PLATFORM}*:${NGC_VERSION}*" -q)            
            exit;;
    esac
done

echo "===================================================="
echo "Dry run by default. Use -c to confirm the deletion. "
echo "===================================================="
echo ""

echo "The following images will be removed once -c option is used."
docker images --filter=reference="${DOCKERHUB_ACCOUNT}/*${PLATFORM}*:${NGC_VERSION}*"