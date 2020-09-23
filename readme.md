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
The mapping configuration file is under `~/.docker/dockpath`. By default, DfR will map your home directory into all created containers. You may also add other mapped directories in the dockpath file.

## Basic Usage
### Create a container and run command
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

### Directory mapping and command substitution

In the case that a host directory is mapped to a different directory in containers, dock will find possible directories/files in your command (but not guaranteed to find all of them), and substitute them with the mapped directories.

For example, if your dockpath looks like this:
```
$HOME:$HOME
/data-on-host:/data-on-container
```
When you call command `dock run py-3.9 python3 experiment/test.py /data-on-host`, the actually called command will be:
```
docker exec -it -u 1001 -e HOME=/ -w / py-3.9 sh -c 'python3 experiment/test.py /data-on-container/.'
```
If you command contains complicated directories, e.g., symlinks, check the printed command to make sure it is correct. A general suggestion is to keep the same directory naming, as long as it does not conflict with the container's system directories (like /usr/local/).

### Commit/Publish/Load a container
DfR containers are no different with a normal container, so you can use normal docker commands to commit/save/delete them.

Commit a container into an image:
```
docker stop py-3.9
docker commit py-3.9 py-3.9-image
```

Serialize an image (to copy between your workstations or for reproducibility):
```
docker save -o py-3.9.img.tar py-3.9-image
```

Load an image tar file:
```
docker load py-3.9.img.tar
```

## Advanced Usage
### X11 forwarding (on local host)

Enable X11 forwarding on docker may be non-trivial. This example provides one solution if you are using docker on your local machine. It does not work if you are ssh-ing into the host.

```
# If you are using docker with root, this command might be needed.
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
