# Dockerfile has three Arguments: tag, pyVer, branch
# tag - tag for Tensorflow Image (default: 1.12.0-py3)
# pyVer - python versions as 'python' or 'python3' (default: python3)
# branch - user repository branch to clone (default: main, other option: test)
#
# To build the image:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> --build-arg arg=value .
# or using default args:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> .


# DEEPaaS API V2 requires python3.6
# set this tag for our custom built TF image
ARG tag=1.12.0-py36

# Base image, e.g. tensorflow/tensorflow:1.12.0
# DEEPaaS API V2 requires python3.6,
# use our custom built Tensorflow images
FROM deephdc/tensorflow:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Dogs breed detector based on deep learning. Uses DEEPaaS API

# default is python3 now
ARG pyVer=python3

# What user branch to clone (!)
ARG branch=main

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         graphviz \
         curl \
         wget \
         $pyVer-setuptools \
         $pyVer-pip \
         $pyVer-dev \
         $pyVer-wheel && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    if [ "$pyVer" = "python3" ] ; then \
       ln -s /usr/bin/pip3 /usr/bin/pip && \
       if [ ! -e /usr/bin/python ]; then \
          ln -s /usr/bin/python3 /usr/bin/python; \
       fi; \
    fi && \
    python --version && \
    pip --version

# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV RCLONE_CONFIG=/srv/.rclone/rclone.conf

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# Initialization scripts
# deep-start can install JupyterLab or VSCode if requested
RUN git clone https://github.com/ai4os/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start

# Necessary for the Jupyter Lab terminal
ENV SHELL /bin/bash

# Install user app:
RUN git clone -b $branch https://github.com/ai4os-hub/dogs_breed_det && \
    cd  dogs_breed_det && \
    pip install --no-cache-dir -e . && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    cd ..

# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring  and Jupyter ports
EXPOSE 6006 8888

# Launch deepaas
CMD ["deepaas-run", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]
