ARG L4T_VERSION=35.1.0
ARG base_image=yaoyuh/l4t-torch-tensorrt:r${L4T_VERSION}_02_python
FROM ${base_image}

# This takes more than 1 hour on Xavier AGX.
RUN pip3 install --no-cache-dir \
    git+https://github.com/scikit-learn/scikit-learn.git@1.2.0

# Entrypoint command
CMD /bin/bash
