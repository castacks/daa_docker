# The base image.
ARG base_image=yaoyuh/ngc_x86_daa:22.12_02_scikit

# Single stage build.
FROM ${base_image}

# As for today, NGC 22.12 contains Pillow 9.2.0 which is not compiled against freetype. 
# This leads the problem of "The _imagingft C module is not installed" when try to
# import Pillow. We need to uninstall Pillow and reinstall it with freetype before
# installing Fiftyone.
# References:
# https://forums.developer.nvidia.com/t/the-imagingft-c-module-is-not-installed/82763
# https://pytorch.org/blog/running-pytorch-models-on-jetson-nano/
# https://github.com/leollon/mysite-project/issues/7
# https://stackoverflow.com/questions/4011705/python-the-imagingft-c-module-is-not-installed
RUN pip3 uninstall -y Pillow \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
            libfreetype-dev libjpeg-dev libpng-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Re-install Pillow and then install Fiftyone.
RUN pip3 install --no-cache-dir Pillow \
 && pip3 install --no-cache-dir fiftyone

# Entrypoint command
CMD /bin/bash
