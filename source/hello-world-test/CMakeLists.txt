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

cmake_minimum_required(VERSION 3.18...3.24)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# Must be called prior to a project being defined.
#
CMAKE_POLICY(SET CMP0091 NEW)

SET(CMAKE_CXX_STANDARD 20)

# Compiler ID gets generated here by cmake:
#
PROJECT(hello-world-test
        VERSION 0.1.0
        DESCRIPTION "Generates Functional Workout Prescription and Schedule."
        HOMEPAGE_URL "https://github.com/wsberry"
        LANGUAGES CXX
        )

# Generate versioning header.
#
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/version.h.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/version.hh"
)

include_directories("${CMAKE_SOURCE_DIR}/include")

# Setup the Docker ENTRYPOINT scripts to be available in the IDE if one
# is being used. Note that the Docker VM will require the entry-point
# scripts to compile a given project in the Docker image.
#
set(entry_point_scripts "${CMAKE_SOURCE_DIR}/entry-points/build.sh")
source_group("entry-points" FILES  ${entry_point_scripts} )

IF(NOT EXISTS  ${entry_point_scripts} )
  MESSAGE(FATAL_ERROR "This does not exist:  \"${CMAKE_SOURCE_DIR}/entry-points/build.sh\"")
ENDIF()

# Note: Apple specific properties are ignore on other operating systems.
#       Uncomment to create a bundle.

add_executable(${PROJECT_NAME}
#   MACOSX_BUNDLE
   main.cpp
        ${CMAKE_SOURCE_DIR}/include/slx/compiler-support.hh
   ${entry_point_scripts}
)

#set_target_properties(${PROJECT_NAME}
#    PROPERTIES
#    BUNDLE NO
#    #XCODE_EMBED_APP_EXTENSIONS
#    XCODE_PRODUCT_TYPE
#    com.apple.product-type.app-extension)

MESSAGE(STATUS
   "Using ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION} using C++ standard version ${CMAKE_CXX_STANDARD}\n")
