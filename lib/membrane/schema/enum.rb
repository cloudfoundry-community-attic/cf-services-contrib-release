require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::Enum < Membrane::Schema::Base
  attr_reader :elem_schemas

  def initialize(*elem_schemas)
    @elem_schemas = elem_schemas
    @elem_schema_str = elem_schemas.map { |s| s.to_s }.join(", ")
  end

  def validate(object)
    @elem_schemas.each do |schema|
      begin
        schema.validate(object)
        return nil
      rescue Membrane::SchemaValidationError
      end
    end

    emsg = "Object #{object} doesn't validate" \
           + " against any of #{@elem_schema_str}"
    raise Membrane::SchemaValidationError.new(emsg)
  end
end
