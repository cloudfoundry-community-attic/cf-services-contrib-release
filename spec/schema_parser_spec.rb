require "spec_helper"

describe Membrane::SchemaParser do
  let(:parser) { Membrane::SchemaParser.new }

  describe "#parse" do
    it "should leave instances derived from Membrane::Schema::Base unchanged" do
      old_schema = Membrane::Schema::ANY

      parser.parse { old_schema }.should == old_schema
    end

    it "should translate 'any' into Membrane::Schema::Any" do
      schema = parser.parse { any }

      schema.class.should == Membrane::Schema::Any
    end

    it "should translate 'bool' into Membrane::Schema::Bool" do
      schema = parser.parse { bool }

      schema.class.should == Membrane::Schema::Bool
    end

    it "should translate 'enum' into Membrane::Schema::Enum" do
      schema = parser.parse { enum(bool, any) }

      schema.class.should == Membrane::Schema::Enum

      schema.elem_schemas.length.should == 2

      elem_schema_classes = schema.elem_schemas.map { |es| es.class }

      expected_classes = [Membrane::Schema::Bool, Membrane::Schema::Any]
      elem_schema_classes.should == expected_classes
    end

    it "should translate 'dict' into Membrane::Schema::Dictionary" do
      schema = parser.parse { dict(String, Integer) }

      schema.class.should == Membrane::Schema::Dictionary

      schema.key_schema.class.should == Membrane::Schema::Class
      schema.key_schema.klass.should == String

      schema.value_schema.class.should == Membrane::Schema::Class
      schema.value_schema.klass.should == Integer
    end

    it "should translate classes into Membrane::Schema::Class" do
      schema = parser.parse { String }

      schema.class.should == Membrane::Schema::Class

      schema.klass.should == String
    end

    it "should fall back to Membrane::Schema::Value" do
      schema = parser.parse { 5 }

      schema.class.should == Membrane::Schema::Value
      schema.value.should == 5
    end

    describe "when parsing a list" do
      it "should raise an error when no element schema is supplied" do
        expect do
          parser.parse { [] }
        end.to raise_error(ArgumentError, /must supply/)
      end

      it "should raise an error when supplied > 1 element schema" do
        expect do
          parser.parse { [String, String] }
        end.to raise_error(ArgumentError, /single schema/)
      end

      it "should parse '[<expr>]' into Membrane::Schema::List" do
        schema = parser.parse { [String] }

        schema.class.should == Membrane::Schema::List

        schema.elem_schema.class.should == Membrane::Schema::Class
        schema.elem_schema.klass.should == String
      end
    end

    describe "when parsing a record" do
      it "should raise an error if the record is empty" do
        expect do
          parser.parse { {} }
        end.to raise_error(ArgumentError, /must supply/)
      end

      it "should parse '{ <key> => <schema> }' into Membrane::Schema::Record" do
        schema = parser.parse do
          { "string" => String,
            "ints"   => [Integer],
          }
        end

        schema.class.should == Membrane::Schema::Record

        str_schema = schema.schemas["string"]
        str_schema.class.should == Membrane::Schema::Class
        str_schema.klass.should == String

        ints_schema = schema.schemas["ints"]
        ints_schema.class.should == Membrane::Schema::List
        ints_schema.elem_schema.class.should == Membrane::Schema::Class
        ints_schema.elem_schema.klass.should == Integer
      end

      it "should handle keys marked with 'optional()'" do
        schema = parser.parse { { optional("test") => Integer } }

        schema.class.should == Membrane::Schema::Record
        schema.optional_keys.to_a.should == ["test"]
      end
    end
  end
end
