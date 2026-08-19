#!/usr/bin/env bash

# Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ex

# First install Rust x86_64-unknown-linux-gnu for all targets.
# This is required to install host tools for cargo.

mkdir rust_install
tar xf /tmp/downloads/rust.tar.xz -C rust_install --strip-components=1

# This installs into /usr/local/bin
./rust_install/install.sh --prefix=$RUST_INSTALL_PREFIX

rm -rf rust_install

# Now install rust-std for the target if it's different from x86_64-unknown-linux-gnu
# The target location must match where the rustc above was installed

if [ -f "/tmp/downloads/rust-std-$TARGET.tar.xz" ]; then
    mkdir rust-std
    tar xf "/tmp/downloads/rust-std-$TARGET.tar.xz" -C rust-std --strip-components=1

    ./rust-std/install.sh --prefix=$RUST_INSTALL_PREFIX

    rm -rf rust-std
else
    echo "No rust-std artifact found for target: $TARGET" >&2
fi

# Now install rust-src (solely for the rust-analyzer proper work for now)
mkdir rust-src
tar xf /tmp/downloads/rust-src.tar.xz -C rust-src --strip-components=1

./rust-src/install.sh --prefix=$RUST_INSTALL_PREFIX --components=rust-src

rm -rf rust-src

mkdir -p /.cargo
cat <<EOF > /.cargo/config.toml
[target.$ARCHITECTURE-unknown-linux-gnu]
linker = "/opt/cross/bin/$ARCHITECTURE-linux-gnu-gcc"
EOF

if [[ $ARCHITECTURE != "x86_64" ]]
then
cat <<EOF >> /.cargo/config.toml
runner = "/usr/bin/qemu-$ARCHITECTURE -L /opt/cross/$ARCHITECTURE-linux-gnu/sysroot"

[target.x86_64-unknown-linux-gnu]
linker = "/usr/bin/clang"
EOF
fi
