# Copyright (c) 2009-2011 VMware, Inc.

module VCAP
  module Services
    module Terracotta
      class TerracottaError < VCAP::Services::Base::Error::ServiceError
        # 31100 - 31199  Terracotta-specific Error
        TERRACOTTA_SAVE_INSTANCE_FAILED        = [31100, HTTP_INTERNAL, "Could not save instance: %s"]
        TERRACOTTA_DESTORY_INSTANCE_FAILED     = [31101, HTTP_INTERNAL, "Could not destroy instance: %s"]
        TERRACOTTA_FIND_INSTANCE_FAILED        = [31102, HTTP_NOT_FOUND, "Could not find instance: %s"]
        TERRACOTTA_START_INSTANCE_FAILED       = [31103, HTTP_INTERNAL, "Could not start instance: %s"]
        TERRACOTTA_STOP_INSTANCE_FAILED        = [31104, HTTP_INTERNAL, "Could not stop instance: %s"]
        TERRACOTTA_INVALID_PLAN                = [31105, HTTP_INTERNAL, "Invalid plan: %s"]
        TERRACOTTA_CLEANUP_INSTANCE_FAILED     = [31106, HTTP_INTERNAL, "Could not cleanup instance, the reasons: %s"]
        TERRACOTTA_CONNECT_INSTANCE_FAILED     = [31107, HTTP_INTERNAL, "Could not connect terracotta instance"]
        TERRACOTTA_SET_INSTANCE_PASS_FAILED    = [31108, HTTP_INTERNAL, "Could not set terracotta instance password"]
        TERRACOTTA_RESTORE_FILE_NOT_FOUND      = [31109, HTTP_INTERNAL, "Could not find terracotta restore data file %s"]
        TERRACOTTA_BAD_SERIALIZED_DATA         = [31110, HTTP_INTERNAL, "File %s can't be verified"]
        TERRACOTTA_RUN_SYSTEM_COMMAND_FAILED   = [31111, HTTP_INTERNAL, "Failed to run system command %s, stdout: %s, stderr: %s"]
        TERRACOTTA_START_INSTANCE_TIMEOUT       = [31322, HTTP_INTERNAL, "Timeout to start terracotta server for instance %s"]
      end
    end
  end
end
