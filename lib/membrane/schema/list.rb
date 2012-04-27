require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::List < Membrane::Schema::Base
  attr_reader :elem_schema

  def initialize(elem_schema)
    @elem_schema = elem_schema
  end

  def validate(object)
    if !object.kind_of?(Array)
      emsg = "Expected instance of Array, given instance of #{object.class}"
      raise Membrane::SchemaValidationError.new(emsg)
    end

    errors = {}

    object.each_with_index do |elem, ii|
      begin
        @elem_schema.validate(elem)
      rescue Membrane::SchemaValidationError => e
        errors[ii] = e.to_s
      end
    end

    if errors.size > 0
      emsg = errors.map { |ii, e| "At index #{ii}: #{e}" }.join(", ")
      raise Membrane::SchemaValidationError.new(emsg)
    end
  end
end
