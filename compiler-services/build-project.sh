#!/usr/bin/env bash
#!/bin/bash

# -----------------------------------------------------------------------------------------
# Copyright 2022 William S Berry
# email: wberry.cpp@gmail.com
# github: https://github.com/wsberry
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
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

# Note: Using Docker Volumes to mount the local directory contents into the docker container instance.
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
