ARG base_image=theairlab/l4t-daa:04_3d
FROM ${base_image}


# requirements for model running

RUN pip install pandas
RUN pip install scikit-image

# Entrypoint command
CMD /bin/bash
