
# Docker for DAA #

# Introduction #

This repo contains the useful docker files and scripts for the Aircraft Detecion and Avoidance project. You can find pre-built docker images, docker files, and helper scripts here. The docker usage targets both x86 (ordinary desktop CPU/GPU) and arm (aarch64, Jetson platforms) architectures.

# Pre-built images #

__NOTE__: All the pre-built images have the `root` as the default user. This is not a good practice and it leads to issues when trying to give GUI support to the docker container. The user is encouraged to create a wrapper docker image based on any of the pre-built images and add an appropriate non-root user to the wrapper docker image. Please refer to the "Adding the host user to an image" section for more details.

Pre-built images can be found at our [Docker Hub repository][dockerhub_repo]. The convention of the image tag is `<Docker Hub account>`/ngc_`<platform>`\_daa:`<NGC version>`\_`<suffix>`. Where the place holders are 
- __Docker Hub account__: The account name of the Docker Hub.
- __platform__: Can be `x86` or `arm`. Use `arm` on Jetson devices.
- __NGC version__: The version of the NGC image with out the `-py3` suffix. E.g. 22.12.
- __suffix__: An ordered name showing the functions of the image.

An example image tag could be
```
yaoyuh/ngc_arm_daa:22.12_03_fiftyone
```
which is an image for the Jetson device based on NGC PyTorch 22.12 and it provides nesseary functions for [FiftyOne](https://voxel51.com/). Note that the `suffix` is only for documentation purpose. The user needs to look at the actual docker files to get a sense of what are in the image without running the image.

[dockerhub_repo]: https://abc.com

# Scripts for creating docker containers #

__NOTE__: It is strongly recommended to follow the "Adding the host user to an image" section to create a wrapper docker image for working with the scripts provided here.

In the `scripts` folder, there are two script files for starting a docker container for development. Namely `starty_docker.sh` and `start_docker_x.sh`, with the `_x` one being used for GUI (X server) support.

To use these scripts, it is recommended to make a copy of a script and modify the necessary arguments for the `docker run` command. One important detail is that these scripts assume that the `home` folder of the user inside the docker container is mounted from outside. This makes things easier for working with tools like [Wandb][wandburl] where user login information is saved to and retreived from the `home` folder by default. E.g., when working with [Wandb][wandburl], the user won't need to login manually every time the `wandb.login()` is executed because the necessary credentials are saved under the `home` folder. If the docker image is built locally by following the "Building images locally" section or a wrapper image is created by following the "Adding the host user to an image" section, the initial content of the `home` folder of the image is automatically copied to the host. Refer to these sections for more details.

[wandburl]: https://docs.wandb.ai/

To start a docker conatiner and enter it immediately, use the following command

```bash
cd <scripts/>
./start_docker.sh <docker image with tag>
```

The conatiner created by these scripts are not got removed automatically. The user need to do `docker rm` before running the script with the same image tag.

# Adding the host user to an image #

It is recommended to create a wrapper image and add the host user to the wrapper image. This has several benefits:
- No file permission issues in and out of the container.
- Friendly to GUI-enabled applications.
- Provides an extra layer of security such that the user won't accidentally change or delete mounted host files.

A dedicated script, `add_user_2_image.sh`, is provided to help to add the host user to an image. The usage is

```bash
cd <scripts/>
./add_user_2_image.sh <input image tag> <new/wrapper image tag> <parent directory for copying the home folder>
```

where the last argument is a directory uner it the ENTIRE `/home/<host user name>` is copied AS A WHOLE object. This means that there will be a new folder with the name of `<host user name>` under the `<parent directory for copying the home folder>`. Be very careful about this behavior and do not confuse it with the actual `home` folder of the host.

For a fresh start, it is recommended to manually remove the `<host user name>` directory before running the `add_user_2_image.sh` script.

# Building images locally #

Two separete scripts are provided for building images locally for `x86` and `arm` platforms. They are `build_x86_images.sh` and `build_arm_images.sh`. The reason for not providing a single script with options to choose platform is that building images is still under development and the procedures are not stable. Once we have a more stable/robust procedure, the scripts will be redesigned.

To use any of the scripts, e.g. `build_arm_images.sh`, do

```bath
cd <scripts/>
./build_arm_images.sh \
    <Docker Hub account> \
    <NGC version> \
    <mounted home folder>
```

An concrete example could be

```bash
./build_arm_images.sh yaoyuh 22.12 /home/airlab/Projects/daa/home_docker
```

Several images will be built progressively. In case of a failure, the user can comment out some parts of the script, make necessary changes to the docker file and re-run again. Then previously successfully built images serve as warm start (base images) of the modified docker file. If the whole build procedure is finished, then there will be an image with a `99_local` suffix in the tag. This is the final image that has the host user already added. The images built by the above example command are

```
REPOSITORY                          TAG                   IMAGE ID       CREATED        SIZE
yaoyuh/ngc_arm_daa                  22.12_99_local        c81c29b3d17a   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa                  22.12_03_fiftyone     30b6524183b2   2 hours ago    15.1GB
yaoyuh/ngc_arm_daa                  22.12_02_scikit       80998a4cc6df   26 hours ago   14.4GB
yaoyuh/ngc_arm_daa                  22.12_01_base         ddcf0403d2ad   26 hours ago   14.4GB
```

# Remove a series of images based on NGC version #

__NOTE__: Use with causion.

When a newer NGC version is available, we can remove a series of images based on an old NGC version by the `remove_images.sh` script. 

First perform a dry run.

```bash
cd <scripts/>
./remove_images.sh <Docker Hub account> <platform> <NGC version>
```

The following is an example

```
$ ./remove_images.sh yaoyuh arm 22.12   
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
$ ./remove_images.sh yaoyuh arm 22.12 -c
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
