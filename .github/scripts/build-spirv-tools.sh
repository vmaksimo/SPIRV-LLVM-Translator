#!/usr/bin/env bash
# Builds SPIRV-Tools at the given branch or tag and installs it into the given
# prefix. Run from the directory where SPIRV-Tools should be cloned.
#
# Usage: build-spirv-tools.sh <ref> <install-dir>
set -euo pipefail

ref=$1
install_dir=$2

git clone --depth=1 --branch "$ref" https://github.com/KhronosGroup/SPIRV-Tools SPIRV-Tools
git -C SPIRV-Tools log -1
python3 SPIRV-Tools/utils/git-sync-deps
cmake -S SPIRV-Tools -B SPIRV-Tools/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$install_dir" \
  -DSPIRV_SKIP_TESTS=ON \
  -G "Unix Makefiles"
make -C SPIRV-Tools/build install -j"$(nproc)"
