require "set"

require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::Bool < Membrane::Schema::Base
  TRUTH_VALUES = Set.new([true, false])

  def validate(object)
    if !TRUTH_VALUES.include?(object)
      emsg = "Expected instance of true or false, given #{object}"
      raise Membrane::SchemaValidationError.new(emsg)
    end
  end
end
