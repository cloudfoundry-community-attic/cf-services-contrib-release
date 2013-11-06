directory "/var/vcap/packages" do
  owner "vcap"
  group "vcap"
  mode "0755"
  recursive true
end

link "/var/vcap/packages/java7" do
  to "/usr/lib/jvm/java-7-oracle" 
  link_type :symbolic
end
