# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@base_images_docker//package_managers:download_pkgs.bzl", "download_pkgs")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(
    "@bazel_toolchains//rules/container:docker_toolchains.bzl",
    "language_tool_layer",
    "toolchain_container",
)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

bzl_library(
    name = "lib",
    srcs = glob(["*.bzl"]),
)

download_pkgs(
    name = "android_test_debs",
    additional_repos = [
        "deb [arch=i386] http://archive.ubuntu.com/ubuntu/ xenial main restricted",
        "deb [arch=i386] http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted",
    ],
    image_tar = "@ubuntu1604//image",
    packages = [
        "cpio",
        "libpulse-dev",
        "libstdc++6:i386",
        "lsof",
        "xvfb",
        "zlib1g:i386",
    ],
)

# Required as the base image for android-test-ltl in order to be able to
# install foreign architecture (i386) debian packages.
toolchain_container(
    name = "ubuntu1604_i386",
    base = "@ubuntu1604//image",
    directory = "/var/lib/dpkg",
    files = ["//layers/ubuntu1604/android_test:arch"],
)

language_tool_layer(
    name = "android-test-ltl",
    base = ":ubuntu1604_i386.tar",
    installables_tar = "@ubuntu1604_android_test_debs//file",
)

container_test(
    name = "test",
    configs = [
        ":tests.yaml",
    ],
    image = ":android-test-ltl",
    verbose = True,
)
