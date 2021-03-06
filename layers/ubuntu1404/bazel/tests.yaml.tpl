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

schemaVersion: "2.0.0"

commandTests:
- name: 'check-bazel'
  command: 'bazel'
  args: ['version']
  expectedOutput: ['Build label: {_BAZEL_REVISION}']
  # 'check-ar' is used to test binutils.
- name: 'check-ar'
  command: 'ar'
  args: ['--version']
  expectedOutput: ['GNU ar .*']
- name: 'check-patch'
  command: 'patch'
  args: ['--version']
  expectedOutput: ['GNU patch .*']
- name: 'check-unzip'
  command: 'unzip'
  expectedOutput: ['.*Usage: unzip .*']
- name: 'check-zip'
  command: 'zip'
  args: ['--version']
  expectedOutput: ['.*This is Zip.*']
- name: 'check-git'
  command: 'git'
  args: ['--version']
  expectedOutput: ['git version .*']
- name: 'check-wget'
  command: 'wget'
  args: ['--version']
  expectedOutput: ['GNU Wget.* built on linux-gnu.*']
- name: 'check-realpath'
  command: 'realpath'
  args: ['--version']
  # It outputs to stderr.
  expectedError: ['realpath version .*']
- name: 'check-file'
  command: 'file'
  args: ['--version']
  expectedOutput: ['file-*']
- name: 'check-xz'
  command: 'xz'
  args: ['--version']
  expectedOutput: ['liblzma *']

fileExistenceTests:
- name: 'bazelrc'
  path: '/etc/bazel.bazelrc'
  shouldExist: true
