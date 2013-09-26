# Copyright (c) 2009-2011 VMware, Inc.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..")
require "util"
require "terracotta_error"

module VCAP::Services::Terracotta::Snapshot
  include VCAP::Services::Base::AsyncJob::Snapshot

  def init_localdb(database_url)
    DataMapper.setup(:default, database_url)
  end

  def terracotta_provisioned_service
    VCAP::Services::Terracotta::Node::ProvisionedService
  end

  def init_setting(prefix)
    @config_command_name = prefix + "-config"
    @shutdown_command_name = prefix + "-shutdown"
    @save_command_name = prefix + "-save"
    @terracotta_port = 25001
    @terracotta_timeout = 2
    options = {}
    @config.each {|k, v| options[k.to_sym] = v}
    terracotta_provisioned_service.init(options)
  end

  # Dump a database into files and save the snapshot information into terracotta.
  class CreateSnapshotJob < BaseCreateSnapshotJob
    include VCAP::Services::Terracotta::Snapshot
    include VCAP::Services::Terracotta::Util

    def execute
      init_localdb(@config["local_db"])
      init_setting(@config["command_rename_prefix"])

      dump_path = get_dump_path(name, snapshot_id)
      FileUtils.mkdir_p(dump_path)
      filename = "dump.rdb"
      dump_file_name = File.join(dump_path, filename)

      srv = terracotta_provisioned_service.get(name)
      result = dump_terracotta_data(srv, dump_path)
      raise "Failed to execute dump command to #{name}" unless result

      dump_file_size = -1
      File.open(dump_file_name) {|f| dump_file_size = f.size}
      complete_time = Time.now
      snapshot = {
        :snapshot_id => snapshot_id,
        :size => dump_file_size,
        :files => [filename],
        :manifest => {
          :version => 1
        }
      }

      snapshot
    end
  end

  # Rollback data from snapshot files.
  class RollbackSnapshotJob < BaseRollbackSnapshotJob
    include VCAP::Services::Terracotta::Util
    include VCAP::Services::Terracotta::Snapshot

    def execute
      @config_command_name = @config["command_rename_prefix"] + "-config"
      @shutdown_command_name = @config["command_rename_prefix"] + "-shutdown"
      @save_command_name = @config["command_rename_prefix"] + "-save"
      init_localdb(@config["local_db"])
      init_setting(@config["command_rename_prefix"])

      srv = terracotta_provisioned_service.get(name)
      snapshot_file_path = @snapshot_files[0]
      raise "Can't snapshot file #{snapshot_file_path}" unless File.exists?(snapshot_file_path)

      result = import_terracotta_data(srv, get_dump_path(name, snapshot_id))
      raise "Failed execute import command to #{name}" unless result
      srv.pid = result
      srv.save

      true
    end
  end
end
