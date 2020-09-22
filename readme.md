# Docker-for-Researcher

Docker-for-Researcher (DfR) is a wrapper script that keeps the advantages of Docker for reproducibility and dependency separation, but also makes running everything in docker fast and effortless on the host, like that:
`dock run <container-tag> python3 experiment/test.py /data-on-host` ,
where `<container-tag>` is a custom container set up by DfR.

## Prerequisite

[Docker](https://docs.docker.com/engine/install/) or [nvidia-docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).
Tested on Ubuntu 18.04 only.

## Setup

### Clone this repo and run setup
```
git clone https://github.com/RalphMao/Docker-for-Researcher.git
cd Docker-for-Researcher
bash setup.sh
```
### Configure directory mapping 
The mapping configuration file is under `~/.docker/dockpath`. All configured source paths in host machine will be mapped and mounted in every docker container created by DfR. 

## Use cases 
### Create your first DfR container
Suppose you have a code under development at `~/experiment/test.py`. On the host machine, it runs with Python-3.5 by `python3 experiment/test.py /test-data`. Now you would like to test it with Python-3.9 inside a docker container, as installing Python-3.9 may be cumbersome or conflicting on the host. 
First pull a python-3.9 image.
```
docker pull python:3.9.0rc2-slim-buster
```
Next you can start a container with tag `py-3.9`, and dock command will set every essential configurations like user id, directory mapping.
```
dock start py-3.9 python:3.9.0rc2-slim-buster
```
After that you will be able to run every command in docker like in the host!
```
dock run py-3.9 python3 experiment/test.py /data-on-host
```
If you figure that there is still missing dependency like numpy, you can install it with root privilege (or just enter the container like normal and install everything).
```
dock rootrun py-3.9 pip install numpy
```

## Known issues
* No X11 forwarding support. Setting up X11 forwarding is non-trivial on host.
* Directory remapping may cause unwanted changes to your original command. Therefore, it is recommended to use the same directory naming in host/container to avoid potential directory resolving issues.

