# Docker-for-Researcher

Docker-for-Researcher (DfR) provides a research-orientied style of using Docker. 
It keeps the reproducibility and dependency separation advantanges of Docker, meanwhile makes running everything in docker fast and effortless on the host, like that:
```
dock run <container-tag> python3 dir_on_host/test.py /data-on-host
```
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

## Basic Usage
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
dock run py-3.9 python3 --version
```
If you figure that there is still missing dependency like numpy, you can install it with root privilege (or just enter the container like normal and install everything).
```
dock run --root py-3.9 "apt update; apt install python-numpy"
# ";" could be interpreted by shell and break the command into two
```

## Advanced Usage
### X11 forwarding (on local host)

Enable X11 forwarding on docker may be non-trivial. This example provides one solution if you are using docker on your local machine. It does not work if you are ssh-ing into the host.

```
# If you are using docker with root, this command might be needed
# xhost +local:root
```

Pull nvidia `cudagl` docker image, or build your custom image with OpenGL support.

```
docker pull nvidia/cudagl:10.1-devel-ubuntu18.04
```

Start a container with X11 forwarding turned on.

```
dock start --x11 cudagl nvidia/cudagl:10.1-devel-ubuntu18.04
```

Install an GUI app (mesa-utils in this case).

```
dock run --root cudagl apt-get update
dock run --root cudagl apt-get install mesa-utils -y
```

You should now be able to see graphic contents.

```
dock run cudagl glxgears
```


## Known issues
* Directory remapping may cause unwanted changes to your original command. Therefore, it is recommended to use the same directory naming in host/container to avoid potential directory resolving issues.
* Passing strings into the command may be problematic, as it is likely to be preprocessed by shell and misinterpreted by dock.
