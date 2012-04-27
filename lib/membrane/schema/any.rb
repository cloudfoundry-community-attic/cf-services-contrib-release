require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::Any < Membrane::Schema::Base
  def validate(object)
    nil
  end
end
