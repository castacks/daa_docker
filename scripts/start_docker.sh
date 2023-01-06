#!/bin/bash

# Detect the system architecture.
UNAME=$(uname -m)
if [ "$UNAME" = "x86_64" ]; then
    ARCH="x86"
elif [ "$UNAME" = "aarch64" ]; then
    ARCH="arm"
else
    echo "Unsupported architecture: $UNAME"
    exit 1
fi

if [ "${ARCH}" = "arm" ]; then
    DOCKER_RUN_NVIDIA="--runtime nvidia"
else
    DOCKER_RUN_NVIDIA="--gpus all"
fi

docker run \
    -it \
    --volume="/external/home/${USER}/data/safe_intelligence/:/data/" \
    --volume="/external/home/${USER}/Projects/daa/:/code/" \
    --volume="/external/home/${USER}/Projects/daa/home_docker/${USER}/:/home/${USER}" \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --net=host \
    --privileged \
    --group-add audio \
    --group-add video \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    --name daa \
    ${DOCKER_RUN_NVIDIA} \
    $1 \
    /bin/bash

