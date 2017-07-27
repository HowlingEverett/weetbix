require "spec_helper"

require "weetbix"

module Weetbix
  describe Namespace do
    subject { Weetbix.namespaced(::Types, "urn:everydayhero:types:") }

    it "should round trip via #dump/#load with json-ld @type" do
      bar = sample_bar

      expected_json = sample_bar_json_with_type("urn:everydayhero:types:Bar")

      json = subject.dump(bar)
      json.freeze

      expect(json).to eq expected_json
      obj = subject.load(json)
      expect(obj).to eq bar
    end
  end
end
