require "spec_helper"


describe Membrane::Schema::Base do
  describe "#validate" do
    let(:schema) { Membrane::Schema::Base.new }

    it "should raise error" do
      expect { schema.validate }.to raise_error
    end

    it "should deparse" do
      schema.deparse.should == schema.inspect
    end
  end
end
