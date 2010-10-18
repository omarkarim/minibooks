#
# Author:: Omar Karim <omar@mobdub.com>
# Cookbook Name:: app_gems
# Recipe:: default
#
# Copyright 2009-2010, Mobdub LLC
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

gem_package "memcached" do
  version "1"
end

gem_package "json" do
  version "1.2.3"
end

gem_package "fast_xs" do
  version "0.7.3"
end

# gem_package "authlogic" do
#   version "2.1.1"
# end
