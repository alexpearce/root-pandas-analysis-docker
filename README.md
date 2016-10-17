# A Dockerfile for pandas and ROOT

Create a container suitable for a Python-based analysis of ROOT files 🐍.

Comes with the most common Python scientific analysis goodies, namely numpy, 
matplotlib, pandas, and scipy, but also packages for getting data from 
[ROOT][root] files, specifically [root-numpy][root-numpy] and 
[root-pandas][root-pandas].

## Usage

Fetch the pre-built container from [Docker hub][docker-hub-image]:

```
$ docker pull alexpearce/root-pandas-analysis
```

With no commands, it runs a Jupyter notebook server bound to port 8888:

```bash
$ docker run -p 8888:8888 alexpearce/root-pandas-analysis
```

To interact with the container:

```bash
$ docker run -p 8888:8888 -it alexpearce/root-pandas-analysis bash
```

To mount the current working directory in the container and work
interactively:

```bash
$ docker run -p 8888:8888 -it -v `pwd`:/work alexpearce/root-pandas-analysis bash
```

The `/work` directory in the container is the default working directory
To make sure that files created in the container belong to the user running
the docker command, pass the ID and group ID of the user running `docker` as 
environment variables:

```bash
$ docker run -e LOCAL_USER_ID=`id -u $USER` -e LOCAL_GROUP_ID=`id -g $USER` ...
```

A typical invocation of this container might look like:

```bash
  $ docker run \
    -it \
    -v `pwd`:/work \
    -e LOCAL_USER_ID=`id -u $USER` -e LOCAL_GROUP_ID=`id -g $USER` \
    alexpearce/root-pandas-analysis <command to run>
```

## Building

Clone this repository and build it like any other container:

```bash
$ docker build -t <container-name> .
```

where `<container-name>` is the label to give the built image.

[root]: https://root.cern.ch/
[root-numpy]: http://rootpy.github.io/root_numpy/
[root-pandas]: https://github.com/ibab/root_pandas
