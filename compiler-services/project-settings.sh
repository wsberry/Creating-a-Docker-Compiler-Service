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

# TODO: Consider generating a bash script from CMake for various operating systems.
# TODO: Make project directory array based to support multiple projects.
#
PROJECT_NAME="hello-world-test"
PROJECT_DIR_NAME="hello-world-test"
DOCKER_WORKDIR="project" # i.e., the .dockerfile 'WORKDIR'

BUILD_TYPE="Release;Debug"
REPO_SCRIPTS_DIR="scripts"
REPO_SOURCE_DIR="source"
REPO_INCLUDE_DIR="include"
SLX_INCLUDE_DIR="slx"
CMAKE_BINARY_DIR="_build"               # Where CMake configuration and generation outputs should go.
INSTALL_DIR="${CMAKE_BINARY_DIR}/_bin"  # This is where we will copy the build results to.
ENTRY_POINTS_DIR="entry-points"
OS_PLATFORM="alpine-latest"

if [[ -z $RUN_VERBOSE ]];
then
  RUN_VERBOSE="false"
fi

if [[ -e "../scripts/core.sh" ]];
then
	source "../scripts/core.sh"
else
	echo -e "\n${TAB}Unable to find bash scripts directory: '../scripts/core.sh'\n"
	#
	# The following stops execution if the last command in the pipeline had an error.
	# Since the core.sh library was not found the script most likely cannot continue
	# without errors so the script process is aborted.
	#
	set -e
	exit 0
fi

# Note:
#
# An attempt has been made in this bash script to use the naming conventions that CMake
# and Docker use. Therefore you may want to be aware of the following distinctions.
#
# There are two predefined variables in CMake: CMAKE_SOURCE_DIR and PROJECT_SOURCE_DIR.
# CMAKE_SOURCE_DIR refers to the top-level source directory that contains a CMakeLists.txt,
# while PROJECT_SOURCE_DIR refers to the source directory of the most recent project()
# command.
#
# They are often the same, but a common workflow when using CMake is to use add_subdirectory
# to add libraries. And in these instances, any CMAKE_SOURCE_DIR in that inner library will
# refer to the outer project's root rather than a given project's own root directory.
#
# Therefore:
#    Acquire the root/main repo directory. This is the top-level source directory that
#    contains the main CMakeLists.txt.
#
CMAKE_SOURCE_DIR=$(cd "$(dirname "$0")" && pwd)

function find_cmake_source_dir()
{
  filter_directories="compiler-services"
  filter_directories+=("entry-points")
  filter_directories+=("scripts")
  for test_dir in "${filter_directories[@]}"
  do
   if [[ "${CMAKE_SOURCE_DIR}" == *"$test_dir"* ]];
     then
        remove_dir_from_path="/$test_dir"
        CMAKE_SOURCE_DIR="${CMAKE_SOURCE_DIR/$remove_dir_from_path}"
     fi
  done
}

function create_docker_environment_file()
{
  # Create the docker run --env-file env.txt file.
  #
  # Define environment variables to be imported by the Docker container.
  #
  rm -f env.txt
  echo "OS_PLATFORM=${OS_PLATFORM}" >> env.txt
  echo "BUILD_TYPE=${BUILD_TYPE}" >> env.txt
  echo "REPO_SOURCE_DIR=${REPO_SOURCE_DIR}" >> env.txt
  echo "CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}" >> env.txt
  echo "CMAKE_SOURCE_DIR=${DOCKER_WORKDIR}" >> env.txt
  echo "ENTRY_POINTS_DIR=${ENTRY_POINTS_DIR}" >> env.txt
  echo "INSTALL_DIR=${INSTALL_DIR}" >> env.txt
  echo "PROJECT_NAME=${PROJECT_NAME}" >> env.txt
  echo "PROJECT_DIR_NAME=${PROJECT_DIR_NAME}" >> env.txt
  echo "RUN_VERBOSE=${RUN_VERBOSE}" >> env.txt
}

# Use to make sure the expected directories and files exist.
#
function validate_settings()
{
  # Require a CMakeList.txt file to exist in either the root repo directory or in a project directory:
  #
  if [[ ! -e "${CMAKE_SOURCE_DIR}/CMakeLists.txt" && ! -e "${CMAKE_SOURCE_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/CMakeLists.txt" ]];
  then
    echo -e "${IRed}Error:${IDefault} Unable to locate a CMake project file 'CMakeLists.txt' in these locations:\n"\
            "\n - '${CMAKE_SOURCE_DIR}/CMakeLists.txt'"\
            "\n - '${CMAKE_SOURCE_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}/CMakeLists.txt'"\
            "\nThe installed source configuration is missing files.\n"
    set -e
    exit 0
  fi

  # Check that these directories exist
  #
  test_volume_directories="${CMAKE_SOURCE_DIR}"
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${INSTALL_DIR}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${CMAKE_BINARY_DIR}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${REPO_SCRIPTS_DIR}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${REPO_SOURCE_DIR}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${REPO_SOURCE_DIR}/${PROJECT_DIR_NAME}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${REPO_INCLUDE_DIR}")
  test_volume_directories+=("${CMAKE_SOURCE_DIR}/${REPO_INCLUDE_DIR}/${SLX_INCLUDE_DIR}")

  if [[ "true" == "${RUN_VERBOSE}" ]];
  then
    echo -e "\n${IYellow}Docker Volume Directories:${IDefault}"
  fi

  found_error="false"
  for test_dir in "${test_volume_directories[@]}"
  do
    if [[ ! -d "${test_dir}" ]];
    then
      # INSTALL_DIR and CMAKE_BINARY_DIR are created by CMake but need to exist to be mounted by Docker.
      #
      if [[ "${CMAKE_SOURCE_DIR}/${INSTALL_DIR}" != "${test_dir}" && "${CMAKE_SOURCE_DIR}/${CMAKE_BINARY_DIR}" != "${test_dir}" ]];
      then
        echo -e "\n ${IRed}Error:${IDefault} Directory, ${test_dir}, does not exist!"
        found_error="true"
      else
        mkdir -p "${test_dir}"
      fi
    else
      if [[ "true" == "${RUN_VERBOSE}" ]];
      then
        echo -e " - ${test_dir}"
      fi
    fi
  done
  echo -e " "

  if [[ "true" == "${found_error}" ]];
  then
      echo -e " Missing directories and files...unable to finish processing build request."
      set -e
      exit
  fi
}


