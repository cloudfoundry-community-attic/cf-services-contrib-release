# Copyright (c) 2009-2011 VMware, Inc.
require "terracotta_service/common"

class VCAP::Services::Terracotta::Provisioner < VCAP::Services::Base::Provisioner

  include VCAP::Services::Terracotta::Common

end
