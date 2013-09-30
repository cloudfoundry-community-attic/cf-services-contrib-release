VERSION = "3.7.5"

group "vcap" do
  action :create
end

user "vcap" do
  supports :manage_home => false
  gid "vcap"
  shell "/bin/bash"
end

directory "/var/vcap/packages" do
  owner "vcap"
  group "vcap"
  mode "0755"
  recursive true
end

remote_file "/tmp/terracotta-#{VERSION}.tar.gz" do
  source "http://d2zwv9pap9ylyd.cloudfront.net/terracotta-#{VERSION}.tar.gz"
  checksum "3c8c346a343595d76aeb3b8ad5fbadb7"
end

bash "install terracotta" do
  cwd "/tmp"
  code <<-BASH
    tar xfz terracotta-#{VERSION}.tar.gz 
    mv terracotta-#{VERSION} /var/vcap/packages/terracotta#{VERSION.gsub('.', '')}
  BASH
end
