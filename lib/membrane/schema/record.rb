require "set"

require "membrane/errors"
require "membrane/schema/base"

module Membrane
  module Schema
  end
end

class Membrane::Schema::Record < Membrane::Schema::Base
  attr_reader :schemas
  attr_reader :optional_keys

  def initialize(schemas, optional_keys = [])
    @optional_keys = Set.new(optional_keys)
    @schemas = schemas
  end

  def validate(object)
    unless object.kind_of?(Hash)
      emsg = "Expected instance of Hash, given instance of #{object.class}"
      raise Membrane::SchemaValidationError.new(emsg)
    end

    key_errors = {}

    @schemas.each do |k, schema|
      if object.has_key?(k)
        begin
          schema.validate(object[k])
        rescue Membrane::SchemaValidationError => e
          key_errors[k] = e.to_s
        end
      elsif !@optional_keys.include?(k)
        key_errors[k] = "Missing key"
      end
    end

    if key_errors.size > 0
      emsg = "{ " + key_errors.map { |k, e| "#{k} => #{e}" }.join(", ") + " }"
      raise Membrane::SchemaValidationError.new(emsg)
    end
  end
end
