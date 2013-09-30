COMMON_DIR = "/var/vcap/store/terracotta_common/bin"

directory COMMON_DIR do
  owner "vcap"
  group "vcap"
  mode "0755"
  recursive true
end

%w[warden_service_ctl utils.sh].each do |file|
  cookbook_file "#{COMMON_DIR}/#{file}" do
    source file
    owner "vcap"
    group "vcap"
    mode "0755"
  end
end
