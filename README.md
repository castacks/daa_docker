
# Docker for DAA #

- [Docker for DAA](#docker-for-daa)
- [Introduction](#introduction)
- [Major packages](#major-packages)
- [Pre-built images](#pre-built-images)
- [Scripts for creating docker containers](#scripts-for-creating-docker-containers)
- [Building images locally](#building-images-locally)
- [Remove a series of images](#remove-a-series-of-images)
- [Who to talk to](#who-to-talk-to)
  - [Point of contact:](#point-of-contact)

# Introduction #

This repo contains useful docker files and scripts for the Aircraft Detecion and Avoidance project. You can find the pre-built docker images, docker files, and helper scripts here. The docker usage targets Jetson AGX Orin architectures.

# Major packages #

| Base Image | CUDA | Python | PyTorch          | Torch-TensorRT | ROS |
|-------------|------|--------|------------------|----------------|-----|
| nvcr.io/nvidia/l4t-pytorch:r35.1.0-pth1.12-py3       | 11.7 | 3.8.10 | 1.12 | release1.1        |  ROS2   |

# Pre-built images #

__NOTE__: All the pre-built images have the `root` as the default user. This is not a good practice and it leads to issues when trying to give GUI support to a docker container. The user is encouraged to create a wrapper docker image based on any of the pre-built images and add an appropriate non-root user to the wrapper image. 

```
sudo usermod -aG docker airlab # replace airlab with your user name.
# need to reboot to take effect
cat /etc/group
```


Pre-built images can be found in our Docker Hub repository for [ARM][arm_repo] architectures. The convention of the image tag is `<Docker Hub account>`/`<platform>`\_daa:`<revision version>`\_`<suffix>`. Where the placeholders are 
- __Docker Hub account__: A Docker Hub account name. This part could be any valid name if the images are built locally following the [Building images locally](#building-images-locally) section.
- __platform__: l4t for Jetson devices.
- __suffix__: An ordered name showing the functions of the image.

An example image tag could be
```
theairlab/l4t-daa:03_ros2
```

[arm_repo]: https://hub.docker.com/layers/theairlab/l4t-daa/03_ros2/images/sha256-eca3c98f16887226c49d0f1812aa9790ebff9f79c05c42479d509022324f40db?context=repo

# Scripts for creating docker containers #


To start a docker container and enter it immediately, use the following command

```bash
xhost + 
docker run -it --rm --runtime nvidia --ulimit memlock=-1 --ulimit stack=67108864 --net=host --ipc=host --pid=host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -v /data:/data theairlab/l4t-daa:03_ros2

```
Here, if you need to use opencv to visualize images in docker, "xhost +" and "-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY" would enable it;

 -v arguments mounts the /data on local machine to the docker, modify it refer to you code folder for accessing data;

The container created by these scripts does not get removed automatically. The user needs to do `docker rm` before running the script with the same image tag.



# Building images locally #

To build the images locally, do

```bash
cd Torch-TensorRT
docker build -t theairlab/l4t-torch-tensorrt:r35.1.0-pth1.12-ttrt-release-1.1  -f docker/Dockerfile.l4t --build-arg BASE=r35.1.0-pth1.12 .

cd ..
docker build -t theairlab/l4t-torch-tensorrt:01 - < /data/daa_docker_new/requirements.dockerfile --build-arg base_image=theairlab/l4t-torch-tensorrt:r35.1.0-pth1.12-ttrt-release-1.1


```
We build it in two steps.
- In the first step, we build a docker for the torch-tensorrt, change the -t argunments to the name you use based on the format of `<Docker Hub account>`/`<image name>`:`<tag>`, this will build the torch-tensorrt docker; 
- the second step is to install the required packages for the daa code to run properly, replace `theairlab/l4t-torch-tensorrt:r35.1.0-pth1.12-ttrt-release-1.1` to the name you have for the torch-tensorrt docker image, -t argument still will give the newly build docker a name, which can be run in [Scripts for creating docker containers](#scripts-for-creating-docker-containers)



Images will be built progressively. In case of a failure, the user can comment out some parts of the script, make necessary changes to the docker file and re-run again. Then previous successfully built images serve as warm start (base images) of the modified docker file. The images built by the above example command on a Jetson device are

```
REPOSITORY                     TAG                                IMAGE ID       CREATED        SIZE
theairlab/l4t-torch-tensorrt   01                                 6b5886195467   21 hours ago   15.9GB
theairlab/l4t-torch-tensorrt   r35.1.0-pth1.12-ttrt-release-1.1   aac85b74f56d   22 hours ago   12.9GB

```

# Remove a series of images #

__NOTE__: docker rmi `IMAGE ID`


# Who to talk to #

Please create GitHub issues if you find any problems.

## Point of contact: ##

Zelin Ye \<zeliny@andrew.cmu.edu\>
