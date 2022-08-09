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

# Alpine is a Linux distribution built around musl libc and BusyBox.
# The image is 5 MB in size and has access to a package repository 
# that is much more complete than other BusyBox based images. 
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
  && apk upgrade \
  && apk add --no-cache \
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
