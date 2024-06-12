# The base image.
ARG base_image=yaoyuh/ngc_x86_daa:22.12_03_fiftyone

# Single stage build.
FROM ${base_image}

# Install VPI
RUN apt-get update \
    && apt-get install gnupg \
    && apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc \
    && apt-get install software-properties-common \
    && add-apt-repository 'deb https://repo.download.nvidia.com/jetson/x86_64/focal r36.2 main' \
    && apt-get update \
    && apt-get install libnvvpi3 vpi3-dev vpi3-samples \
    && apt-get install python3.8-vpi3 \
    && apt-get install vpi3-cross-aarch64-l4t

# Entrypoint command
CMD /bin/bash
