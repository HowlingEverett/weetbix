require "spec_helper"

describe Weetbix do
  it "should round trip via dry-thingy with jsonld @type" do
    bar = sample_bar

    ns = Weetbix.namespaced(Types, "urn:everydayhero:types:")

    expected_json = sample_bar_json_with_type("urn:everydayhero:types:Bar")

    json = ns.dump(bar)
    expect(json).to eq expected_json
    obj = ns.load(json)
    expect(obj).to eq bar
  end
end
