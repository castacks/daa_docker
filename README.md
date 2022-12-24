
# Docker for DAA #

- [Docker for DAA](#docker-for-daa)
- [Introduction](#introduction)
- [Pre-built images](#pre-built-images)
- [Scripts for creating docker containers](#scripts-for-creating-docker-containers)
- [Adding the host user to an image](#adding-the-host-user-to-an-image)
- [Building images locally](#building-images-locally)
- [Remove a series of images based on NGC version](#remove-a-series-of-images-based-on-ngc-version)
- [Who to talk to](#who-to-talk-to)
  - [Point of contact:](#point-of-contact)

# Introduction #

This repo contains useful docker files and scripts for the Aircraft Detecion and Avoidance project. You can find the pre-built docker images, docker files, and helper scripts here. The docker usage targets both x86 (ordinary desktop CPU/GPU) and ARM (aarch64, Jetson platforms) architectures.

# Pre-built images #

__NOTE__: All the pre-built images have the `root` as the default user. This is not a good practice and it leads to issues when trying to give GUI support to a docker container. The user is encouraged to create a wrapper docker image based on any of the pre-built images and add an appropriate non-root user to the wrapper image. Please refer to the [Adding the host user to an image](#adding-the-host-user-to-an-image) section for more details.

Pre-built images can be found in our Docker Hub repository for [x86][x86_repo] and [ARM][arm_repo] architectures. The convention of the image tag is `<Docker Hub account>`/ngc_`<platform>`\_daa:`<NGC version>`\_`<suffix>`. Where the placeholders are 
- __Docker Hub account__: The account name of the Docker Hub.
- __platform__: Can be `x86` or `arm`. Use `arm` on Jetson devices.
- __NGC version__: The version of the [NGC PyTorch image][ngc_pytorch] with out the `-py3` suffix. E.g., 22.12.
- __suffix__: An ordered name showing the functions of the image.

An example image tag could be
```
yaoyuh/ngc_arm_daa:22.12_03_fiftyone
```
which is an image for the Jetson device based on NGC PyTorch 22.12 and it provides necessary functions for [FiftyOne](https://voxel51.com/). Note that the `suffix` is only for documentation purposes. The user needs to look at the actual docker files to get a sense of what is in an image without running the image.

[x86_repo]: https://hub.docker.com/repository/docker/yaoyuh/ngc_x86_daa
[arm_repo]: https://hub.docker.com/repository/docker/yaoyuh/ngc_arm_daa
[ngc_pytorch]: https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch

# Scripts for creating docker containers #

__NOTE__: It is strongly recommended to follow the [Adding the host user to an image](#adding-the-host-user-to-an-image) section to create a wrapper docker image for working with the scripts provided here.

In the `scripts` folder, there are two script files for starting a development docker container. Namely `start_docker.sh` and `start_docker_x.sh`, where `_x` means GUI (X server) support.

To use these scripts, it is recommended to make a copy of a script and modify the necessary arguments for the `docker run` command. One important detail is that these scripts assume that the `home` folder of the user inside the docker container is mounted from outside. This makes things easier for working with tools like [Wandb][wandburl] where user login information is saved to and retrieved from the `home` folder by default. E.g., when working with [Wandb][wandburl], the user won't need to log in manually every time the `wandb.login()` is executed because the necessary credentials are saved under the `home` folder that is mounted externally. If a docker image is built locally by following the [Building images locally](#building-images-locally) section or a wrapper image is created by following the [Adding the host user to an image](#adding-the-host-user-to-an-image) section, the initial content of the `home` folder of the image is automatically copied to the host. Refer to these sections for more details.

[wandburl]: https://docs.wandb.ai/

To start a docker container and enter it immediately, use the following command

```bash
cd <scripts/>
./start_docker.sh <docker image with tag>
```

The container created by these scripts does not get removed automatically. The user needs to do `docker rm` before running the script with the same image tag.

# Adding the host user to an image #

It is recommended to create a wrapper image and add the host user to it. This has several benefits:
- No file permission issues in and out of the container.
- Friendly to GUI-enabled applications.
- Provides an extra layer of security such that the user won't accidentally change or delete mounted host files.

A dedicated script, `add_user_2_image.sh`, is provided to help to add the host user to an image. The usage is

```bash
cd <scripts/>
./add_user_2_image.sh <input image tag> <new/wrapper image tag> <parent directory for copying the home folder>
```

where the last argument is a directory under it the ENTIRE `/home/<host user name>` is copied AS A WHOLE object. This means that there will be a new folder with the name of `<host user name>` under the `<parent directory for copying the home folder>`. Be very careful about this behavior and do not confuse it with the actual `home` folder of the host.

For a fresh start, it is recommended to manually remove the copied `<host user name>` directory before running the `add_user_2_image.sh` script.

# Building images locally #

To build the images locally, do

```bath
cd <scripts/>
./build_images.sh \
    <Docker Hub account> \
    <NGC version> \
    <mounted home folder>
```

where the `<mounted home folder>` is discussed in detail in the [Adding the host user to an image](#adding-the-host-user-to-an-image) section.

An concrete example could be

```bash
./build_images.sh yaoyuh 22.12 /home/airlab/Projects/daa/home_docker
```

Several images will be built progressively. In case of a failure, the user can comment out some parts of the script, make necessary changes to the docker file and re-run again. Then previous successfully built images serve as warm start (base images) of the modified docker file. When the whole build procedure finishes, there will be an image with a `99_local` tag suffix. This is the final image that has the host user already added. The images built by the above example command on a Jetson device are

```
REPOSITORY                          TAG                   IMAGE ID       CREATED        SIZE
yaoyuh/ngc_arm_daa                  22.12_99_local        c81c29b3d17a   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa                  22.12_03_fiftyone     30b6524183b2   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa                  22.12_02_scikit       80998a4cc6df   26 hours ago   14.4GB
yaoyuh/ngc_arm_daa                  22.12_01_base         ddcf0403d2ad   26 hours ago   14.4GB
```

# Remove a series of images based on NGC version #

__NOTE__: Use with caution.

When a newer NGC version is available, we can remove a series of images that are based on an old NGC version by the `remove_images.sh` script. 

First, perform a dry run.

```bash
cd <scripts/>
./remove_images.sh <Docker Hub account> <NGC version>
```

The following is an example on a Jetson device.

```
$ ./remove_images.sh yaoyuh 22.12   
====================================================
Dry run by default. Use -c to confirm the deletion. 
====================================================

The following images will be removed once -c option is used.
REPOSITORY           TAG                 IMAGE ID       CREATED        SIZE
yaoyuh/ngc_arm_daa   22.12_99_local      c81c29b3d17a   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa   22.12_03_fiftyone   30b6524183b2   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa   22.12_02_scikit     80998a4cc6df   26 hours ago   14.4GB
yaoyuh/ngc_arm_daa   22.12_01_base       ddcf0403d2ad   26 hours ago   14.4GB
```

To confirm the deletion, add the `-c` option to the command line. (The HASH codes are example ones)

```
$ ./remove_images.sh yaoyuh 22.12 -c
Removing...
REPOSITORY           TAG                 IMAGE ID       CREATED        SIZE
yaoyuh/ngc_arm_daa   22.12_99_local      c81c29b3d17a   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa   22.12_03_fiftyone   30b6524183b2   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa   22.12_02_scikit     80998a4cc6df   26 hours ago   14.4GB
yaoyuh/ngc_arm_daa   22.12_01_base       ddcf0403d2ad   26 hours ago   14.4GB
Untagged: yaoyuh/ngc_arm_daa:22.12_99_local
Deleted: sha256:c81c29b3d17abeb8cc6af4ae13fca4a689006382e88138852cd0828d1614792d
Deleted: sha256:de7e3dbb9f8dd155c68603ce6c980026a26de8b110eb73d517143a7867285e04
...
<lots of other sha256 codes>
...
Deleted: sha256:21ac1ba1456cb91c479068db1f9bf57101a7304f93d1aa04f64c0997f088a462
Untagged: yaoyuh/ngc_arm_daa:22.12_03_fiftyone
Deleted: sha256:30b6524183b20722489269aa6f182267ea165cb436026016dcba0536c0a6d07f
Untagged: yaoyuh/ngc_arm_daa:22.12_02_scikit
Deleted: sha256:80998a4cc6df26e1b0cc67342d48630ffa8862cc9cd2e2326e32657ae61224f4
Untagged: yaoyuh/ngc_arm_daa:22.12_01_base
Deleted: sha256:ddcf0403d2ad2190bfca1ef4b8d0987f6483e3e8a93de65dd0a3a7ab49caccbd
```

# Who to talk to #

Please create GitHub issues if you find any problems.

## Point of contact: ##

Yaoyu Hu \<yaoyuh@andrew.cmu.edu\>
