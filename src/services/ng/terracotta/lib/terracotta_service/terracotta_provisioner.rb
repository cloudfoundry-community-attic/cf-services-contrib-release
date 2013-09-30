# Copyright (c) 2009-2011 VMware, Inc.
require "fileutils"
require "base64"

$LOAD_PATH.unshift File.join(File.dirname __FILE__)
require "common"

class VCAP::Services::Terracotta::Provisioner < VCAP::Services::Base::Provisioner
  include VCAP::Services::Terracotta::Common
end
