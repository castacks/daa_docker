#!/bin/bash

docker run \
    -it \
    --volume="/external/home/airlab/data/safe_intelligence/:/data/" \
    --volume="/external/home/airlab/Projects/daa/:/code/" \
    --volume="/external/home/airlab/Projects/daa/home_docker/${USER}/:/home/${USER}" \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --net=host \
    --runtime nvidia \
    --privileged \
    --group-add audio \
    --group-add video \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    --name daa \
    $1 \
    /bin/bash

