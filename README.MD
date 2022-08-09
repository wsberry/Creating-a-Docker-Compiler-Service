<div class="row"><div class="column">
  <img alt="SLX" src=".images/slx-logo.png" style="zoom: 75%;"/></div><div class="column"><h3><font color='#1976d2'>Creating a Docker Compiler Service</font></h3></div></div>
wsberry@gmail.com


### Overview

Docker is a great tool when cross-compiling projects. It enables you to check for compile time errors while working from an IDE on your local machine and quickly compile the code using a different operating system or compiler version.

This project implements a simple C++ project using CMake that may be compiled from your host environment or from a Docker container that hosts the latest Alpine Linux OS with Clang 14.0 installed. 

The code demonstrated in the hello-world-test project provides a sample of a fold expression and therefore does require C++ 20 when compiling on your local machine.

### Prerequisites

\- [Docker Desktop](https://www.docker.com/products/docker-desktop/)</br>
\-  [Git](https://git-scm.com/)</br>
\-  [CMake](https://cmake.org/)</br>
\-  [Bash](https://www.gnu.org/software/bash/) ([Git bash may be used for Windows](https://git-scm.com/download/win))</br>

------

###### <font color='#1976d2'>Important Note for macOS Users:</font>

Bash 3.2.57 is the default version that comes with the macOS. The scripts provided in this demo require version 5 and above.

To install the latest version of bash on the macOS run `./scripts/install-bash-mac-os.sh` to update your system. On some systems when cloning this repository, the 'executable' attribute may have been removed. Therefore, you may need to run `{sudo} chmod +x install-bash-mac-os.sh` to enable the script to be run as an executable again in bash:
~~~bash
$ sudo chmod +x ./scripts/install-bash-mac-os.sh
$ ./scripts/install-bash-mac-os.sh
~~~

------

### Building the Alpine/Clang 14.0 Build Service

The Dockerfile, `./compiler-services/alpine-latest-clang-14.0-build-service.dockerfile`,  contains the commands to create a Docker image called '<font color='#1976d2'>alpine-latest-clang-14.0-build-service</font>':

~~~bash
# Alpine is a Linux distribution built around musl libc and BusyBox.
#
# https://alpinelinux.org/
#
FROM alpine:latest

LABEL Description = "A Clang 14 Build Service on Alpine Linux Latest."

ENV PROJECT_DIR /project

WORKDIR ${PROJECT_DIR}

# Install dev tools to build the C++ project.
#
RUN apk update \
  && 	apk upgrade \
  && 	apk add --no-cache \
        bash \
        alpine-sdk \
        ccache \
        clang \
        clang-dev \
        cmake \
        dpkg
        # nano
	
# Finalize Setup
#
RUN ln -sf /usr/bin/clang /usr/bin/cc \
  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
  && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 14\
  && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 14\
  && update-alternatives --auto cc \
  && update-alternatives --auto c++ \
  && update-alternatives --display cc \
  && update-alternatives --display c++ \
  && ls -l /usr/bin/cc /usr/bin/c++ \
  && cc --version \
  && c++ --version \
  && clang --version 

# Contains CMake/çompile time instructions.
#
ENTRYPOINT ["./entry-points/build.sh"]
~~~

A helper script named, `./scripts/create-docker-service.sh`, may be used to build or remove any docker images created from this dockerfile:

~~~bash
#!/usr/bin/env bash
#!/bin/bash

source "../scripts/core.sh"

root_dir=${PWD}

CLANG_VERSION="Clang 14.0"

DOCKER_SERVICE_VERSION=1.0.0

DOCKER_WORKDIR="projects"
DOCKER_SERVICE_NAME="alpine-latest-clang-14.0-build-service"
DOCKER_FILE="${DOCKER_SERVICE_NAME}.dockerfile"

LINUX_TYPE="Alpine Linux"
LINUX_URL="https://alpinelinux.org/"

export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

clear

function help_about()
{
	echo -e "\n${IYellow}Overview:${IDefault}\nCreate a Docker image for compiling CPP"\
	        " projects on ${LINUX_TYPE} (${LINUX_URL}) using ${CLANG_VERSION}."\
          "\nThe resulting Docker image is named '${DOCKER_SERVICE_NAME}'."\
          "\n\n${IYellow}Options for using this script:${IPurple}"\
          "  \n   '-b${IDefault} or ${IPurple}--build'"\
          "  \n   '-r${IDefault} or ${IPurple}--remove'${IDefault}\n"\
          "\n${IWhite}Example:${IDefault}\n  ./create-docker-service -b\n"

           ls "${DOCKER_FILE}"
           echo "alpine-latest-clang-14.0-build-service.dockerfile"
}

function remove_service_image()
{
	docker rmi -f "${DOCKER_SERVICE_NAME}:${DOCKER_SERVICE_VERSION}"
}	

function build_service_image()
{
	remove_service_image
	docker build -t "${DOCKER_SERVICE_NAME}:${DOCKER_SERVICE_VERSION}" -f "${DOCKER_FILE}" . 
}

# Run Options:
#
if [[ "-b" == "$1" 	|| "--build" == "$1"  ]]; then
	build_service_image
elif [[ "-r" == "$1" || "--remove" == "$1"  ]]; then
	remove_service_image
else
	help_about
fi
~~~

Once you have the service created you are ready to build the provided project.  The instructions for this are defined in the `./compiler-services/build-project.sh`  bash script:

~~~bash
#!/usr/bin/env bash
#!/bin/bash

# -----------------------------------------------------------------------------------------
# Copyright (c) William Berry
# email: wberry.cpp@gmail.com
# github: https://github.com/wsberry
#
# Description:
#   Use this script to build the 'hello-world-test' project.
#   See the 'help_about' function for the available options.
# -----------------------------------------------------------------------------------------

# Docker Specific Paths.
#
DOCKER_IMAGE_NAME="alpine-latest-clang-14.0-build-service"
DOCKER_FILE="${DOCKER_IMAGE_NAME}.dockerfile"

# DOCKER_IMAGE_VERSION:
#
# The version of the docker image to use. This is a tag that is used when the docker image was created.
#
# I.e.,
#   docker build -t {DOCKER_IMAGE_NAME}:{DOCKER_IMAGE_VERSION} -f {DOCKER_FILE}
#
DOCKER_IMAGE_VERSION=1.0.0

# Project Settings (these are things you may want to make changes to)
#
. project-settings.sh

RUN_VERBOSE="false"
if [[ "$1" == *"v"* ]];
then
  RUN_VERBOSE="true"
fi

# The following are defined in project-settings
#
find_cmake_source_dir
validate_settings
create_docker_environment_file

function help_about()
{
	tabs 3
	echo -e "${IYellow}Options:${IDefault}"\
          "\n ${IPurple} '-bi'${IDefault} - Run build interactively with the Alpine image and Clang 14.0."\
	        "\n ${IPurple} '-bd'${IDefault} - Run build detached with the Alpine image and Clang 14.0."\
	        "\n ${IPurple} '-bl'${IDefault} - Build using the default CMake generator on your account."\
	        "\n ${IPurple} '-ba'${IDefault} - Build all; build on Alpine and your host machine).\n"\
	        "\n${IYellow}Example:${IPurple}  ./build-project.sh -bi\n"\
	        "\n${IYellow}Notes:${IDefault}"\
	        "\n   1. For verbose output add 'v' to the option flag you are using (e.g., -bdv)."\
	        "\n   2. Add 'c' to the option flag to reload cmake and rebuild all  (e.g., -bdc).\n"
}

# Note: Using Docker Volumes to mount the local directory contents into 
#       the docker container instance.
#
#       See 'https://docs.docker.com/storage/volumes/' for details.
#
#       TODO: Create a docker compose example.
#
function build_interactive()
{
  echo -e "\n${IYellow}Building on Alpine (interactive)...${IDefault}"
  sleep 2

  PN="${PROJECT_DIR_NAME}"

  # Note absolute paths are required here.
  #
  docker run --env-file env.txt "-i" --rm --name="build_${PN}_interactive"\
    --mount type=bind,source="${CMAKE_SOURCE_DIR}",target="/${DOCKER_WORKDIR}"\
    "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" bash
}

function build_detached()
{
    echo -e "\n${IYellow}Building on Alpine (detached)...${IDefault}"
    sleep 2

    PN="${PROJECT_DIR_NAME}"

    # Note absolute paths are required here.
    #
    docker run --env-file env.txt -d --rm --name="build_${PN}_detached"\
      --mount type=bind,source="${CMAKE_SOURCE_DIR}",target="/${DOCKER_WORKDIR}"\
      "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}" bash
}

function build_local()
{
  echo -e "\n${IYellow}Building on local Machine...${IDefault}"
  sleep 2
  export LOCAL_MACHINE='true'
  "${CMAKE_SOURCE_DIR}/${ENTRY_POINTS_DIR}/build.sh"
}

# Add 'c' to option key (short form) to clean and rebuild all.
#
if [[ "$1" == *"c"*  ]];
then
  rm -Rf "${CMAKE_SOURCE_DIR}/${INSTALL_DIR}"
  rm -Rf "${CMAKE_SOURCE_DIR}/${CMAKE_BINARY_DIR}"
fi

if [[ "$1" == *"-ba"* || "--build-all" == "$1"  ]];
then
  build_local
  build_interactive

elif [[ "$1" == *"-bi"* || "--build-interactive" == "$1"  ]];
then
	build_interactive

elif [[ "$1" == *"-bd"* || "--build-detached" == "$1"  ]];
then
  build_detached

elif [[ "$1" == *"-bl"* || "--build-local" == "$1"  ]];
then
  build_local

else
	help_about

fi
~~~

A Docker ENTRYPOINT ["./entry-points/build.sh"] is used to implement the CMake commands to build `hello-world-test` project locally or via the provided docker service:
~~~bash
#!/usr/bin/env bash
#!/bin/bash

if [[ -e "./scripts/core.sh" ]];
then
	source "./scripts/core.sh"
else
	if [[ -e "../scripts/core.sh" ]];
	then
		source "../scripts/core.sh"
	else
		echo -e "\n${TAB}Unable to find bash scripts directory: '../scripts/core.sh'\n"
		ls
		#
		# The following stops execution if the last command in the pipeline had an error.
		# Since the core.sh library was not found the script most likely cannot continue
		# without errors so the script process is aborted.
		#
		set -e
		exit 0
	fi
fi

function get_local_machine_settings()
{
	RUN_VERBOSE="true"
	. project-settings.sh
	find_cmake_source_dir
	validate_settings
}

# Acquire the root/main repo directory (i.e., where the root CMakeLists.txt is):
#
CMAKE_SOURCE_DIR=$(cd "$(dirname "$0")" && pwd)

if [[ "${CMAKE_SOURCE_DIR}" == *"entry-points"* ]];
then
  # The following code acquires the root directory from the full path of
  # the compiler-services directory (i.e., we are removing the substr 'entry-points').
  #
  remove_dir_from_path="/entry-points"
  CMAKE_SOURCE_DIR="${CMAKE_SOURCE_DIR/$remove_dir_from_path}"
fi

# Specify the platform
#
if [[ ! -z "${OS_PLATFORM}" ]];
then
	os_platform="${OS_PLATFORM}"
fi

echo -e "\n${IYellow}Building On: ${IBlue}${os_platform}${IDefault}\n"

if [[ "true" == "${LOCAL_MACHINE}" ]];
then
	get_local_machine_settings

	CMAKE_BUILD_DIR="${CMAKE_BINARY_DIR}/${os_platform}"
	CMAKE_BINARY_DIR="${CMAKE_SOURCE_DIR}/${CMAKE_BINARY_DIR}/${os_platform}"
	INSTALL_APPLICATION_PATH="${CMAKE_SOURCE_DIR}/${INSTALL_DIR}/${PROJECT_DIR_NAME}/${os_platform}"
	
	# Target path will be the same on macOS and Linux
	#
	TARGET_PATH="${CMAKE_BINARY_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/${PROJECT_NAME}"

	# Visual Studio supports multiple configurations therefore supports Release/Debug (and perhaps others also).
	# TODO: This is just a quick hack and a generic implementation should be demonstrated.
	#
	if [[ "${os_platform}" == *"windows"* ]];
	then
		TARGET_PATH="${CMAKE_SOURCE_DIR}/${CMAKE_BUILD_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/Debug/${PROJECT_NAME}.exe"
	fi	

else
  #
	# Building from a docker container instance:
	#
	CMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}/${os_platform}"
	INSTALL_APPLICATION_PATH="${CMAKE_SOURCE_DIR}/${INSTALL_DIR}/${PROJECT_DIR_NAME}/${os_platform}/"
	TARGET_PATH="${CMAKE_SOURCE_DIR}/${CMAKE_BINARY_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/${PROJECT_NAME}"
	
fi

# Debug:
#echo "TARGET_PATH: ${TARGET_PATH}"
#echo "CMAKE_BUILD_DIR: ${CMAKE_BUILD_DIR}"
#echo "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}"
#echo "INSTALL_APPLICATION_PATH: ${INSTALL_APPLICATION_PATH}"
#set -e
#exit 0

cmake -S "${CMAKE_SOURCE_DIR}" -B "${CMAKE_BINARY_DIR}"
cmake --build "${CMAKE_BINARY_DIR}"

# Check the target on Windows .
# Make note of the comment above on multi-configuration builds.
#
# TODO: This is just a quick hack and a generic implementation should be demonstrated.
#
if [[ "${os_platform}" == *"windows"* && ! -e "${TARGET_PATH}" ]];
then
	TARGET_PATH="${CMAKE_SOURCE_DIR}/${CMAKE_BUILD_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/Release/${PROJECT_NAME}.exe"
fi

# Copy the application package to the 'install' directory.
#
mkdir -p "${INSTALL_APPLICATION_PATH}"
cp -f "${TARGET_PATH}" "${INSTALL_APPLICATION_PATH}/"

if [[ "${os_platform}" == *"windows"* ]];
then
    "${INSTALL_APPLICATION_PATH}/${PROJECT_NAME}.exe"

elif [[ "${os_platform}" == *"linux"* || "${os_platform}" == *"alpine"* ]];
then
    "${INSTALL_APPLICATION_PATH}/${PROJECT_NAME}"

elif [[ "${os_platform}" == *"darwin"* ]];
then
    open "${INSTALL_APPLICATION_PATH}/${PROJECT_NAME}"

fi

echo -e "\n*** Finished ${APP_SOURCE_PATH}"
~~~

### Future Examples

- [ ] Implement a Docker image for compiling on Windows.
- [ ] Implement a Docker image for compiling on macOS.
- [ ] Implement a Boost Asio and ZeroMQ servers that run inside a docker container.



