require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::Tuple < Membrane::Schema::Base
  attr_reader :elem_schemas

  def initialize(*elem_schemas)
    @elem_schemas = elem_schemas
  end

  def validate(object)
    if !object.kind_of?(Array)
      emsg = "Expected instance of Array, given instance of #{object.class}"
      raise Membrane::SchemaValidationError.new(emsg)
    end

    expected = @elem_schemas.length
    actual = object.length

    if actual != expected
      emsg = "Expected #{expected} element(s), given #{actual}"
      raise Membrane::SchemaValidationError.new(emsg)
    end

    errors = {}

    @elem_schemas.each_with_index do |schema, ii|
      begin
        schema.validate(object[ii])
      rescue Membrane::SchemaValidationError => e
        errors[ii] = e
      end
    end

    if errors.size > 0
      emsg = "There were errors at the following indices: " \
             + errors.map { |ii, err| "#{ii} => #{err}" }.join(", ")
      raise Membrane::SchemaValidationError.new(emsg)
    end

    nil
  end
end
