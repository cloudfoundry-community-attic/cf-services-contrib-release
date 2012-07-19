module Membrane
  module Schema
  end
end

class Membrane::Schema::Base
  # Verifies whether or not the supplied object conforms to this schema
  #
  # @param [Object]  The object being validated
  #
  # @raise [Membrane::SchemaValidationError]
  #
  # @return [nil]
  def validate(object)
    raise NotImplementedError
  end

  def deparse
    Membrane::SchemaParser.deparse(self)
  end
end
