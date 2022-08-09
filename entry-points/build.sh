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


