ARG base_image=theairlab/l4t-daa:03_ros2
FROM ${base_image}


# requirements for model running

RUN pip3 install transforms3d

# Entrypoint command
CMD /bin/bash
