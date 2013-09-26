# Copyright (c) 2009-2011 VMware, Inc.
require "terracotta"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), ".")
require "terracotta_error"

# Terracotta client library doesn't support renamed command, so we override the functions here.
class Terracotta
  def config(config_command_name, action, *args)
    synchronize do |client|
      client.call [config_command_name.to_sym, action, *args] do |reply|
        if reply.kind_of?(Array) && action == :get
          Hash[*reply]
        else
          reply
        end
      end
    end
  end

  def shutdown(shutdown_command_name)
    synchronize do |client|
      client.with_reconnect(false) do
        begin
          client.call [shutdown_command_name.to_sym]
        rescue ConnectionError
          # This means Terracotta has probably exited.
          nil
        end
      end
    end
  end

  def save(save_command_name)
    synchronize do |client|
      client.call [save_command_name.to_sym]
    end
  end
end

module VCAP
  module Services
    module Terracotta
      module Util
        @terracotta_timeout = 2 if @terracotta_timeout == nil

        VALID_CREDENTIAL_CHARACTERS = ("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a

        def generate_credential(length=12)
          Array.new(length) { VALID_CREDENTIAL_CHARACTERS[rand(VALID_CREDENTIAL_CHARACTERS.length)] }.join
        end

        def fmt_error(e)
          "#{e}: [#{e.backtrace.join(" | ")}]"
        end

        def dump_terracotta_data(instance, dump_path=nil)
          terracotta = nil
          begin
            Timeout::timeout(@terracotta_timeout) do
              terracotta = ::Terracotta.new({:host => instance.ip, :port => @terracotta_port, :password => instance.password})
              terracotta.save(@save_command_name)
            end
          rescue => e
            raise TerracottaError.new(TerracottaError::TERRACOTTA_CONNECT_INSTANCE_FAILED)
          ensure
            begin
              terracotta.quit if terracotta
            rescue => e
            end
          end
          if dump_path
            FileUtils.cp(File.join(instance.data_dir, "dump.rdb"), dump_path)
          end
          true
        rescue => e
          @logger.error("Error dump instance #{instance.name}: #{fmt_error(e)}")
          nil
        end

        def import_terracotta_data(instance, dump_path)
          name = instance.name
          dump_file = File.join(dump_path, "dump.rdb")
          instance.stop
          FileUtils.cp(dump_file, instance.data_dir)
          instance.run
          true
        rescue => e
          @logger.error("Failed in import dumpfile to instance #{instance.name}: #{fmt_error(e)}")
          nil
        end

        def get_info(host, port, password)
          info = nil
          terracotta = nil
          Timeout::timeout(@terracotta_timeout) do
            terracotta = ::Terracotta.new({:host => host, :port => port, :password => password})
            info = terracotta.info
          end
          info
        rescue => e
          raise TerracottaError.new(TerracottaError::TERRACOTTA_CONNECT_INSTANCE_FAILED)
        ensure
          begin
            terracotta.quit if terracotta
          rescue => e
          end
        end

        def get_config(host, port, password, key)
          config = nil
          terracotta = nil
          Timeout::timeout(@terracotta_timeout) do
            terracotta = ::Terracotta.new({:host => host, :port => port, :password => password})
            config = terracotta.config(@config_command_name, :get, key)[key]
          end
          config
        rescue => e
          raise TerracottaError.new(TerracottaError::TERRACOTTA_CONNECT_INSTANCE_FAILED)
        ensure
          begin
            terracotta.quit if terracotta
          rescue => e
          end
        end

        def set_config(host, port, password, key, value)
          terracotta = nil
          Timeout::timeout(@terracotta_timeout) do
            terracotta = ::Terracotta.new({:host => host, :port => port, :password => password})
            terracotta.config(@config_command_name, :set, key, value)
          end
        rescue => e
          raise TerracottaError.new(TerracottaError::TERRACOTTA_CONNECT_INSTANCE_FAILED)
        ensure
          begin
            terracotta.quit if terracotta
          rescue => e
          end
        end
      end
    end
  end
end
