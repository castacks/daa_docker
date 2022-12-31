ARG L4T_VERSION=35.1.0
ARG base_image=yaoyuh/l4t-torch-tensorrt:r${L4T_VERSION}_01_base
FROM ${base_image}

# Allow using GUI apps.
# ENV TERM=xterm
ARG DEBIAN_FRONTEND=noninteractive
ARG T_ZONE=New_York
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
 && ln -fs /usr/share/zoneinfo/America/${T_ZONE} /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    tmux \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
	numpy==1.20.3 \
	scikit-image \
	timm \
	seaborn \
	geographiclib \
	filterpy \
	natsort \
	kornia

# Refer to https://forums.developer.nvidia.com/t/error-importerror-usr-lib-aarch64-linux-gnu-libgomp-so-1-cannot-allocate-memory-in-static-tls-block-i-looked-through-available-threads-already/166494/5
ENV LD_PRELOAD=/lib/aarch64-linux-gnu/libGLdispatch.so.0

# Entrypoint command
CMD /bin/bash
