#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc.
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

include_recipe "build-essential"
# include_recipe "ruby_enterprise"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

gem_package "passenger" do
  version node[:passenger_enterprise][:version]
end

nginx_version = node[:nginx][:version]
configure_flags = node[:nginx][:configure_flags].join(" ")
node.set[:nginx][:daemon_disable] = true

remote_file "/tmp/nginx-#{nginx_version}.tar.gz" do
  source "http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

execute "unpack nginx source" do
  command "tar zxf /tmp/nginx-#{nginx_version}.tar.gz -C /tmp"
  action :run
end

# bash "unpack_nginx_source" do
#   cwd "/tmp"
#   code <<-EOH
#     tar zxf nginx-#{nginx_version}.tar.gz
#   EOH
# end

configure_flags = node[:nginx][:configure_flags].join(" ")
nginx_install = node[:nginx][:install_path]
nginx_version = node[:nginx][:version]
nginx_dir = node[:nginx][:dir]

execute "passenger_nginx_module" do
  command %Q{
    passenger-install-nginx-module \
      --auto --prefix=#{nginx_install} \
      --nginx-source-dir=/tmp/nginx-#{nginx_version} \
      --extra-configure-flags='#{configure_flags}'
  }
  # not_if "#{nginx_install}/sbin/nginx -V 2>&1 | grep '#{node[:ruby_enterprise][:gems_dir]}/gems/passenger-#{node[:passenger_enterprise][:version]}/ext/nginx'"
  # notifies :restart, resources(:service => "nginx")
end

# execute "passenger_nginx_module" do
#   command %Q{
#     #{node[:ruby_enterprise][:install_path]}/bin/passenger-install-nginx-module \
#       --auto --prefix=#{nginx_install} \
#       --nginx-source-dir=/tmp/nginx-#{nginx_version} \
#       --extra-configure-flags='#{configure_flags}'
#   }
#   not_if "#{nginx_install}/sbin/nginx -V 2>&1 | grep '#{node[:ruby_enterprise][:gems_dir]}/gems/passenger-#{node[:passenger_enterprise][:version]}/ext/nginx'"
#   # notifies :restart, resources(:service => "nginx")
# end

# bash "compile_nginx_source" do
#   cwd "/tmp"
#   code <<-EOH
#     tar zxf nginx-#{nginx_version}.tar.gz
#     cd nginx-#{nginx_version} && ./configure #{configure_flags}
#     make && make install
#   EOH
#   creates node[:nginx][:src_binary]
# end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

#install init db script
template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  owner "root"
  group "root"
  mode "0755"
end
 
# #install sysconfig file (not really needed but standard)
# template "/etc/sysconfig/nginx" do
#   source "nginx.sysconfig.erb"
#   owner "root"
#   group "root"
#   mode "0644"
# end
# 

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# #register service
# service "nginx" do
#   supports :status => true, :restart => true, :reload => true
#   action :enable
#   subscribes :restart, resources(:bash => "compile_nginx_source")
# end
# 
# %w{ sites-available sites-enabled conf.d }.each do |dir|
#   directory "#{node[:nginx][:dir]}/#{dir}" do
#     owner "root"
#     group "root"
#     mode "0755"
#   end
# end
# 
# %w{nxensite nxdissite}.each do |nxscript|
#   template "/usr/sbin/#{nxscript}" do
#     source "#{nxscript}.erb"
#     mode "0755"
#     owner "root"
#     group "root"
#   end
# end
# 
template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :immediately
end

# cookbook_file "#{node[:nginx][:dir]}/mime.types" do
#   source "mime.types"
#   owner "root"
#   group "root"
#   mode "0644"
#   notifies :restart, resources(:service => "nginx"), :immediately
# end
