# ----------------------------------------------------------------------------------------
# Copyright (c) William Berry
# email: wberry.cpp@gmail.com
# github: https://github.com/wsberry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may freely use this source code and its projects in compliance with the License.
#
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License src distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.18...3.24)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# Must be called prior to a project being defined.
# https://cmake.org/cmake/help/latest/policy/CMP0091.html
#
CMAKE_POLICY(SET CMP0091 NEW)

# Compiler ID gets generated here by cmake:
#
PROJECT(docker-tutorials
        VERSION 1.0.0
        DESCRIPTION "Sample C++ application to build in a Docker image based on Alpine  ."
        HOMEPAGE_URL "https://github.com/wsberry"
        LANGUAGES CXX
        )

SET(CMAKE_CXX_STANDARD 20)


SET(PROJECTS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")

# Add individual projects here:
#
ADD_SUBDIRECTORY("${PROJECTS_DIR}/hello-world-test")