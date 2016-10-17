# Create a container suitable for pandas analysis of ROOT files
#
# Build like any other container:
#   $ docker build -t <container-name> .
# With no commands, runs a Jupyter notebook server bound to port 8888
#   $ docker run -p 8888:8888 <container-name>
# To interact with the container:
#   $ docker run -p 8888:8888 -it <container-name> bash
# To mount the current working directory in the container and work
# interactively:
#   $ docker run -p 8888:8888 -it -v `pwd`:/work <container-name> bash
# The /work directory in the container is the default working directory
# To make sure that files created in the container belong to the user running
# the docker command, pass the user's ID and group ID as environment variables:
#   $ docker run -e LOCAL_USER_ID=`id -u $USER` -e LOCAL_GROUP_ID=`id -g $USER` ...
#
# A typical invocation of this container might look like:
#   $ docker run \
#     -it \
#     -v `pwd`:/work \
#     -e LOCAL_USER_ID=`id -u $USER` -e LOCAL_GROUP_ID=`id -g $USER` \
#     <container-name> <command to run>
FROM continuumio/miniconda3:latest
MAINTAINER Alex Pearce <alex@alexpearce.me>

RUN apt-get clean && apt-get update

# For LaTeX plots with matplotlib
RUN apt-get install -y \
    texlive-base \
    texlive-base-bin \
    texlive-latex-extra \
    texlive-fonts-recommended \
    dvipng

# Needed for the GCC install
RUN apt-get install -y build-essential

# Add gosu so that files written to a location mounted inside the image have
# the same permissions as the user running `docker`
ENV GOSU_VERSION 1.7
RUN set -x \
    && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN conda install -y -c asmeurer gcc=4.8.5
RUN conda install -y -c chrisburr root=6

# Fix bug in ROOT activation script
# https://lhcbqa.web.cern.ch/lhcbqa/494/root-when-installed-with-anaconda-missing-libmultiproc-so
RUN sed -i -- 's/CONDA_ENV_PATH/CONDA_PREFIX/g' /opt/conda/etc/conda/activate.d/activateROOT.sh

# Source the default conda environment to make sure ROOT paths are set
RUN bash -c 'source activate $CONDA_DEFAULT_ENV \
    && pip install matplotlib scipy jupyter \
    && pip install --no-binary root_numpy root_numpy \
    && pip install git+git://github.com/ibab/root_pandas@2001dcc8675d19fce8b15f02f63aa47944eec3d6'

RUN mkdir /etc/skel/.jupyter
COPY docker/jupyter_notebook_config.py /etc/skel/.jupyter/

# Disable the obnoxious RooFit banner
RUN echo 'RooFit.Banner: 0' > /etc/skel/.rootrc

WORKDIR /work

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 8888
CMD jupyter notebook
