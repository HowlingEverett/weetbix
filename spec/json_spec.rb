require "spec_helper"

require "weetbix"
require "oj"

module Weetbix
  describe JsonSerializer do
    subject { Weetbix.serializer(::Types, "urn:everydayhero:types:") }

    it "should round trip via JSON" do
      bar = sample_bar
      expected_json = sample_bar_json_with_type("urn:everydayhero:types:Bar")
      expected_json = Oj.dump expected_json

      json = subject.dump(bar)
      expect(json).to eq expected_json

      obj = subject.load(json)
      expect(obj).to eq bar
    end
  end
end
