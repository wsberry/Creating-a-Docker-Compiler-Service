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

# Install brew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)”

# Install git and bash using brew.
#
brew install git
brew install bash

echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells /usr/local/bin/bash
sudo chpass -s /usr/local/bin/bash $USER

echo -e "\nNote to use the latest installed bash version change '#!/bin/bash' to '#!/usr/bin/env bash'."\
        "\nThis works by finding the latest version of bash and enables the"\
        " scripts to be portable to Linux, Windows, and the macOS."
