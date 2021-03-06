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

load("@base_images_docker//package_managers:apt_key.bzl", "add_apt_key")
load("@base_images_docker//package_managers:download_pkgs.bzl", "download_pkgs")
load("@base_images_docker//util:run.bzl", "container_run_and_extract")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@bazel_toolchains//rules/container:docker_toolchains.bzl", "language_tool_layer", "toolchain_container")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(":revisions.bzl", "OPENJDK_INSTALLER", "OPENJDK_SRC")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

bzl_library(
    name = "lib",
    srcs = glob(["*.bzl"]),
)

add_apt_key(
    name = "java-key-image",
    image = "@ubuntu1404//image",
    keys = [
        "@launchpad_openjdk_gpg//file",
    ],
)

download_pkgs(
    name = "java_debs",
    additional_repos = [
        "deb [arch=amd64] http://ppa.launchpad.net/openjdk-r/ppa/ubuntu/ trusty main",
    ],
    image_tar = ":java-key-image.tar",
    packages = [
        "ca-certificates-java",
        "openjdk-8-jdk-headless",
        "openjdk-8-jre-headless",
    ],
)

# /etc/ssl/certs/java/cacerts is generated when `ca-certificates-java` is
# installed or `update-ca-certificates -f` is run. Because of the timestamp
# embedded, the file is not deterministic.
#
# This target is used to generate a new version of the cacerts file.
container_run_and_extract(
    name = "cacerts_tar",
    commands = [
        "apt-get update",
        "apt-get install -y ca-certificates-java",
        "tar -cvf /cacerts.tar --mtime='1970-01-01' /etc/ssl/certs/java/cacerts",
    ],
    extract_file = "/cacerts.tar",
    image = "@ubuntu1404//image",
)

# Clean up commands to run at the end of container generation to remove any
# build specific files.
JAVA_CLEANUP_COMMANDS = (
    "rm -rf " +
    # Still need to remove the nondeterministic cacerts which is generated when
    # `ca-certificates-java` is installed.
    "/etc/ssl/certs/java/cacerts " +
    "/tmp/hsperfdata_root/* " +
    "/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/classes.jsa " +
    # A dangling symlink created by installing `openjdk-8-jdk-headless`.
    "/usr/lib/jvm/java-8-openjdk-amd64/src.zip"
)

language_tool_layer(
    name = "java-ltl",
    base = "@ubuntu1404//image",
    env = {
        "JAVA_HOME": "/usr/lib/jvm/java-8-openjdk-amd64",
    },
    installables_tar = "@ubuntu1404_java_debs//file",
    installation_cleanup_commands = JAVA_CLEANUP_COMMANDS,
    symlinks = {
        "/usr/bin/java": "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java",
    },
    tars = [
        "@ubuntu1404_java_cacerts//file",
    ],
)

pkg_tar(
    name = "open_jdk_tar",
    package_dir = "/usr/lib/jvm/" + OPENJDK_INSTALLER.revision.rpartition("/")[0],
    tags = ["manual"],
    deps = [
        "@azul_open_jdk//file",
    ],
)

pkg_tar(
    name = "open_jdk_src_tar",
    srcs = [
        "@azul_open_jdk_src//file",
    ],
    package_dir = "/usr/src/jdk/",
    tags = ["manual"],
)

language_tool_layer(
    name = "java11-ltl",
    base = "@ubuntu1404//image",
    tars = [
        ":open_jdk_tar",
        ":open_jdk_src_tar",
    ],
)

# Used by tests only. Replace the placeholders in tests.yaml.tpl with the
# revisions from revisions.bzl.
# For example, /usr/lib/jvm/{_JAVA_REVISION} could be replaced with
# /usr/lib/jvm/11.29.3-ca-jdk11.0.2, and a test will make sure that directory
# exists in the container.
# This avoids the need to update the tests.yaml file every time the revision
# changes.
genrule(
    name = "generate_java_yaml",
    srcs = ["tests.yaml.tpl"],
    outs = ["tests.yaml"],
    cmd = (
        "sed 's|{_SRC_REVISION}|" + OPENJDK_SRC.revision.rpartition("/")[2] +
        "|g; s|{_JAVA_REVISION}|" + OPENJDK_INSTALLER.revision.rpartition("/")[0] +
        "|g' <$< >$@"
    ),
)

# This image is for testing purpose only.
toolchain_container(
    name = "test_image",
    base = "@ubuntu1604//image",
    language_layers = [
        ":java-ltl",
        ":java11-ltl",
    ],
)

container_test(
    name = "test",
    configs = [
        ":tests.yaml",
    ],
    image = ":test_image",
    verbose = True,
)
