#!/bin/bash

BASE_IMAGE=$1
TARGET=$2
HOME_COPY=$3

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DOCKER_FILE=${SCRIPT_DIR}/../dockerfiles/add_user.dockerfile

GROUP_ID=$(id -g)
GROUP_NAME=$(id -gn)

echo "Add the following user info to Docker image $BASE_IMAGE: "
echo "user_id    = ${UID}"
echo "user_name  = ${USER}"
echo "group_id   = ${GROUP_ID}"
echo "group_name = ${GROUP_NAME}"

docker build \
    -f ${DOCKER_FILE} \
    -t ${TARGET} \
    --build-arg base_image=${BASE_IMAGE} \
    --build-arg user_id=${UID} \
    --build-arg user_name=${USER} \
    --build-arg group_id=${GROUP_ID} \
    --build-arg group_name=${GROUP_NAME} \
    .

# Create a temporary Docker container to copy the content of the home directory out to the specific location.
CONTAINER_NAME=adding_user
mkdir -p ${HOME_COPY}
docker container create --name ${CONTAINER_NAME} ${TARGET}
docker container cp ${CONTAINER_NAME}:/home/${USER} ${HOME_COPY}
docker container rm -f ${CONTAINER_NAME}

echo "The content of the home folder has been copied to ${HOME_COPY}. Show the content below: "
ls -al ${HOME_COPY}/${USER}

echo "Done with adding user. "
