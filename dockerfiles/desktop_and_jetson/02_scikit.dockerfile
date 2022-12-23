ARG base_image=yaoyuh/ngc_daa:22.12_01_base
FROM ${base_image}

RUN pip3 install --no-cache-dir \
    scikit-image \
    scikit-learn

# If pip does not find an appropriate pre-built scikit-learn.
# Then we need to compile scikit-learn from source.
# RUN pip3 install --no-cache-dir \
#     git+https://github.com/scikit-learn/scikit-learn.git@1.2.0

# Entrypoint command
CMD /bin/bash
