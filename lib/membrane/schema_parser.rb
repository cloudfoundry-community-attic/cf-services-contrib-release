require "membrane/schema"

module Membrane
end

class Membrane::SchemaParser
  DEPARSE_INDENT = "  ".freeze

  class Dsl
    OptionalKeyMarker = Struct.new(:key)
    DictionaryMarker  = Struct.new(:key_schema, :value_schema)
    EnumMarker        = Struct.new(:elem_schemas)
    TupleMarker       = Struct.new(:elem_schemas)

    def any
      Membrane::Schema::Any.new
    end

    def bool
      Membrane::Schema::Bool.new
    end

    def enum(*elem_schemas)
      EnumMarker.new(elem_schemas)
    end

    def dict(key_schema, value_schema)
      DictionaryMarker.new(key_schema, value_schema)
    end

    def optional(key)
      Dsl::OptionalKeyMarker.new(key)
    end

    def tuple(*elem_schemas)
      TupleMarker.new(elem_schemas)
    end
  end

  def self.parse(&blk)
    new.parse(&blk)
  end

  def self.deparse(schema)
    new.deparse(schema)
  end

  def parse(&blk)
    intermediate_schema = Dsl.new.instance_eval(&blk)

    do_parse(intermediate_schema)
  end

  def deparse(schema)
    case schema
    when Membrane::Schema::Any
      "any"
    when Membrane::Schema::Bool
      "bool"
    when Membrane::Schema::Class
      schema.klass.name
    when Membrane::Schema::Dictionary
      "dict(%s, %s)" % [deparse(schema.key_schema),
                        deparse(schema.value_schema)]
    when Membrane::Schema::Enum
      "enum(%s)" % [schema.elem_schemas.map { |es| deparse(es) }.join(", ")]
    when Membrane::Schema::List
      "[%s]" % [deparse(schema.elem_schema)]
    when Membrane::Schema::Record
      deparse_record(schema)
    when Membrane::Schema::Regexp
      schema.regexp.inspect
    when Membrane::Schema::Tuple
      "tuple(%s)" % [schema.elem_schemas.map { |es| deparse(es) }.join(", ")]
    when Membrane::Schema::Value
      schema.value.inspect
    when Membrane::Schema::Base
      schema.inspect
    else
      emsg = "Expected instance of Membrane::Schema::Base, given instance of" \
             + " #{schema.class}"
      raise ArgumentError.new(emsg)
    end
  end

  private

  def do_parse(object)
    case object
    when Hash
      parse_record(object)
    when Array
      parse_list(object)
    when Class
      Membrane::Schema::Class.new(object)
    when Regexp
      Membrane::Schema::Regexp.new(object)
    when Dsl::DictionaryMarker
      Membrane::Schema::Dictionary.new(do_parse(object.key_schema),
                                       do_parse(object.value_schema))
    when Dsl::EnumMarker
      elem_schemas = object.elem_schemas.map { |s| do_parse(s) }
      Membrane::Schema::Enum.new(*elem_schemas)
    when Dsl::TupleMarker
      elem_schemas = object.elem_schemas.map { |s| do_parse(s) }
      Membrane::Schema::Tuple.new(*elem_schemas)
    when Membrane::Schema::Base
      object
    else
      Membrane::Schema::Value.new(object)
    end
  end

  def parse_list(schema)
    if schema.empty?
      raise ArgumentError.new("You must supply a schema for elements.")
    elsif schema.length > 1
      raise ArgumentError.new("Lists can only match a single schema.")
    end

    Membrane::Schema::List.new(do_parse(schema[0]))
  end

  def parse_record(schema)
    if schema.empty?
      raise ArgumentError.new("You must supply at least one key-value pair.")
    end

    optional_keys = []

    parsed = {}

    schema.each do |key, value_schema|
      if key.kind_of?(Dsl::OptionalKeyMarker)
        key = key.key
        optional_keys << key
      end

      parsed[key] = do_parse(value_schema)
    end

    Membrane::Schema::Record.new(parsed, optional_keys)
  end

  def deparse_record(schema)
    lines = ["{"]

    schema.schemas.each do |key, val_schema|
      dep_key = nil
      if schema.optional_keys.include?(key)
        dep_key = "optional(%s)" % [key.inspect]
      else
        dep_key = key.inspect
      end

      dep_val_schema_lines = deparse(val_schema).split("\n")

      dep_val_schema_lines.each_with_index do |line, line_idx|
        to_append = nil

        if 0 == line_idx
          to_append = "%s => %s" % [dep_key, line]
        else
          # Indent continuation lines
          to_append = DEPARSE_INDENT + line
        end

        # This concludes the deparsed schema, append a comma in preparation
        # for the next k-v pair.
        if dep_val_schema_lines.size - 1 == line_idx
          to_append += ","
        end

        lines << to_append
      end
    end

    lines << "}"

    lines.join("\n")
  end
end
