require "spec_helper"

require "oj"

describe Weetbix do
  it "has a version number" do
    expect(Weetbix::VERSION).not_to be nil
  end

  it "should round trip to JSON" do
    json_s = Weetbix.serializer(Types, "urn:everydayhero:types:")

    bar = sample_bar
    expected_json = sample_bar_json_with_type("urn:everydayhero:types:Bar")
    expected_json = Oj.dump expected_json

    json = json_s.dump(bar)
    expect(json).to eq expected_json

    obj = json_s.load(json)
    expect(obj).to eq bar
  end
end
