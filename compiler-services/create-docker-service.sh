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
	tabs 1
	echo -e "\n${IYellow}Overview:${IDefault}\nCreate a Docker image for compiling CPP"\
	        " projects on ${LINUX_TYPE} (${LINUX_URL}) using ${CLANG_VERSION}."\
          "\nThe resulting Docker image is named '${DOCKER_SERVICE_NAME}'."\
          "\n\n${IYellow}Options for using this script:${IPurple}"\
          "  \n   '-b${IDefault} or ${IPurple}--build'"\
          "  \n   '-r${IDefault} or ${IPurple}--remove'${IDefault}\n"\
          "\n${IWhite}Example:${IDefault}\n  ./create-docker-service -b\n"
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