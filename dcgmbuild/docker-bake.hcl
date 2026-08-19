# Copyright (c) 2025-2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

function commit_ref_slug {
  params = [commit_ref]
  result = "${regex_replace(lower(commit_ref), "[^0-9a-z]", "-")}"
}

variable "ARCHITECTURES" {
  type = list(string)
  default = ["x86_64", "aarch64"]
}

variable "BASE_IMAGE" {
  default = "ubuntu:24.04"
}

variable "GIT_COMMIT" {
  default = "unspecified"
}

variable "GIT_REFERENCE" {}

variable "REGISTRIES" {
  type = list(string)
  default = ["dcgm"]
}

variable "TAG" {
  default = "latest"
}

target "common-host-software" {
  context = "container-images/common-host-software"
  contexts = {
    base_image = "docker-image://${BASE_IMAGE}"
  }
}

target "toolchain" {
  args = {
    ARCHITECTURE = "${architecture}"
  }
  context = "container-images/toolchain"
  contexts = {
    base_image = "docker-image://${BASE_IMAGE}"
    common-host-software = "target:common-host-software"
  }
  labels = {
    "git_commit" = "${GIT_COMMIT}"
  }
  matrix = {
    architecture = ARCHITECTURES
  }
  name = "toolchain-${architecture}"
}

target "dcgmbuild" {
  context = "container-images/dcgmbuild"
  contexts = {
    toolchain = "target:toolchain-${architecture}"
  }
  labels = {
    "git_commit" = "${GIT_COMMIT}"
  }
  matrix = {
    architecture = ARCHITECTURES
  }
  name = "dcgmbuild-${architecture}"
  tags = formatlist("%s/dcgmbuild-${architecture}:${TAG}", REGISTRIES)
}

group "default" {
  targets = formatlist("dcgmbuild-%s", ARCHITECTURES)
}
