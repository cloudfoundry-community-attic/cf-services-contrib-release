require "spec_helper"

describe Membrane::Schema::Dictionary do
  describe "#validate" do
    let (:data) { { "foo" => 1, "bar" => 2 } }

    it "should return an error if supplied with a non-hash" do
      schema = Membrane::Schema::Dictionary.new(nil, nil)

      expect_validation_failure(schema, "test", /instance of Hash/)
    end

    it "should validate each key against the supplied key schema" do
      key_schema = mock("key_schema")

      data.keys.each { |k| key_schema.should_receive(:validate).with(k) }

      dict_schema = Membrane::Schema::Dictionary.new(key_schema,
                                                     Membrane::Schema::Any.new)

      dict_schema.validate(data)
    end

    it "should validate the value for each valid key" do
      key_schema = Membrane::Schema::Class.new(String)
      val_schema = mock("val_schema")

      data.values.each { |v| val_schema.should_receive(:validate).with(v) }

      dict_schema = Membrane::Schema::Dictionary.new(key_schema, val_schema)

      dict_schema.validate(data)
    end

    it "should return any errors for keys or values that didn't validate" do
      bad_data = {
        "foo" => "bar",
        :bar  => 2,
      }

      key_schema = Membrane::Schema::Class.new(String)
      val_schema = Membrane::Schema::Class.new(Integer)
      dict_schema = Membrane::Schema::Dictionary.new(key_schema, val_schema)

      errors = nil

      begin
        dict_schema.validate(bad_data)
      rescue Membrane::SchemaValidationError => e
        errors = e.to_s
      end

      errors.should match(/foo/)
      errors.should match(/bar/)
    end
  end
end
