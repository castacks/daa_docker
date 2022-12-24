#!/bin/bash

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


# This file is obtained from
# https://answers.ros.org/question/300113/docker-how-to-use-rviz-and-gazebo-from-a-container/
# and
# https://medium.com/intro-to-artificial-intelligence/rviz-on-docker-bdf4d0fca5b


# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# It still not working, try running the script as root.

XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data... "
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

echo "Done. "
echo ""
echo "Verifying file contents: "
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh $XAUTH
echo ""
echo "Running docker... "

if [ "${ARCH}" == "arm" ]; then
    DOCKER_RUN_NVIDIA="--runtime nvidia"
else
    DOCKER_RUN_NVIDIA="--gpus all"
fi

docker run \
    -it \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="$XAUTH:$XAUTH" \
    --volume="/external/home/${USER}/data/safe_intelligence/:/data/" \
    --volume="/external/home/${USER}/Projects/daa/:/code/" \
    --volume="/external/home/${USER}/Projects/daa/home_docker/${USER}/:/home/${USER}" \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --net=host \
    --privileged \
    --group-add audio \
    --group-add video \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    --name daa_x \
    ${DOCKER_RUN_NVIDIA} \
    $1 \
    /bin/bash

