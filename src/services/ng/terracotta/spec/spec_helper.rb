# Copyright (c) 2009-2011 VMware, Inc.
$:.unshift File.join(File.dirname(__FILE__), "..")
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)

require "rubygems"
require "rspec"
require "bundler/setup"
require "vcap_services_base"
require "nats/client"
require "vcap/common"
require "datamapper"
require "uri"
require "terracotta"
require "thread"
require "terracotta_service/terracotta_node"
require "terracotta_service/terracotta_error"

def getLogger
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  logger
end

def parse_property(hash, key, type, options = {})
  obj = hash[key]
  if obj.nil?
    raise "Missing required option: #{key}" unless options[:optional]
    nil
  elsif type == Range
    raise "Invalid Range object: #{obj}" unless obj.kind_of?(Hash)
    first, last = obj["first"], obj["last"]
    raise "Invalid Range object: #{obj}" unless first.kind_of?(Integer) and last.kind_of?(Integer)
    Range.new(first, last)
  else
    raise "Invalid #{type} object: #{obj}" unless obj.kind_of?(type)
    obj
  end
end

def config_base_dir
  File.join(File.dirname(__FILE__), "..", "config")
end

def getNodeTestConfig
  config_file = File.join(config_base_dir, "terracotta_node.yml")
  config = YAML.load_file(config_file)
  options = {
    # micellaneous configs
    :logger => getLogger,
    :plan => parse_property(config, "plan", String),
    :capacity => parse_property(config, "capacity", Integer),
    :node_id => parse_property(config, "node_id", String),
    :mbus => parse_property(config, "mbus", String),
    :ip_route => parse_property(config, "ip_route", String, :optional => true),
    :config_template => File.join(File.dirname(__FILE__), "..", "resources/terracotta.conf.erb"),
    :port_range => parse_property(config, "port_range", Range),

    # parse terracotta wardenized-service control related config
    :service_bin_dir => {"2.2" => "/var/vcap/packages/terracotta22", "2.4" => "/var/vcap/packages/terracotta24", "2.6" => "/var/vcap/packages/terracotta26"},
    :service_common_dir => "/var/vcap/store/terracotta_common",

    # terracotta related configs
    :max_memory => parse_property(config, "max_memory", Integer),
    :command_rename_prefix => parse_property(config, "command_rename_prefix", String),
    :max_clients => parse_property(config, "max_clients", Integer, :optional => true),
    :supported_versions => parse_property(config, "supported_versions", Array),
    :default_version => parse_property(config, "default_version", String),

    # hardcode unit test related directories to /tmp dir
    :base_dir => "/tmp/terracotta_instances",
    :local_db_file => "/tmp/terracotta_node_" + Time.now.to_i.to_s + ".db",
    :service_log_dir => "/tmp/terracotta_log",
    :image_dir => "/tmp/terracotta_image",
    :migration_nfs => "/tmp/migration",
    :disabled_file => "/tmp/terracotta_instances/DISABLED",
  }
  options[:local_db] = "sqlite3:" + options[:local_db_file]
  options
end

def terracotta_echo(host, port, password=nil)
  if password
    terracotta = Terracotta.new({:host => host, :port => port, :password => password})
  else
    terracotta = Terracotta.new({:host => host, :port => port})
  end
  terracotta.echo("")
  terracotta.quit
  true
end

def terracotta_set(host, port, password, key, value)
  terracotta = Terracotta.new({:host => host, :port => port, :password => password})
  terracotta.set(key, value)
  terracotta.quit if terracotta
  true
end

def terracotta_get(host, port, password, key)
  terracotta = Terracotta.new({:host => host, :port => port, :password => password})
  value = terracotta.get(key)
  terracotta.quit if terracotta
  value
end

def terracotta_del(host, port, password, key)
  terracotta = Terracotta.new({:host => host, :port => port, :password => password})
  value = terracotta.del(key)
  terracotta.quit if terracotta
  true
end

def terracotta_save(host, port, password, command)
  terracotta = Terracotta.new({:host => host, :port => port, :password => password})
  terracotta.save(command)
  terracotta.quit if terracotta
  true
end
