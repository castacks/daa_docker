ARG base_image=theairlab/l4t-torch-tensorrt:r35.1.0-pth1.12-ttrt1.2.0 
FROM ${base_image}


RUN pip3 install --no-cache-dir \
    git+https://github.com/scikit-learn/scikit-learn.git@1.2.0

# requirements for model running
RUN pip3 install timm
RUN pip3 install matplotlib
RUN pip3 install pytz
RUN pip3 install geographiclib
RUN pip3 install kornia
RUN pip3 install natsort
RUN pip3 install transforms3d
RUN pip3 install filterpy

# ros2 installation
RUN apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

RUN apt install software-properties-common -y
RUN add-apt-repository universe

RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update

# fix for opencv shared library errors
RUN apt-get purge '*opencv*' -y
RUN apt autoremove -y

RUN apt upgrade -y
RUN apt install ros-foxy-desktop python3-argcomplete -y
RUN apt install ros-foxy-ros-base python3-argcomplete -y
RUN apt install ros-dev-tools -y
# Entrypoint command
CMD /bin/bash