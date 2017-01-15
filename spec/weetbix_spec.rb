require "spec_helper"

describe Weetbix do
  it "has a version number" do
    expect(Weetbix::VERSION).not_to be nil
  end

  it "should round trip via dry-thingy" do
    bar = sample_bar
    expected_json = sample_bar_json

    json = Weetbix.dump(bar)
    expect(json).to eq expected_json

    obj = Weetbix.load(json, Types::Bar)
    expect(obj).to eq bar
  end

  it "raises errors with ambiguous types" do
    ambiguous_object = sample_ambiguous

    expect do
      Weetbix.dump(ambiguous_object)
    end.to raise_error(Weetbix::AmbiguousTypeError)
  end

  it "raises errors with unserializable types" do
    unserializable_object = sample_unserializable

    expect do
      Weetbix.dump(unserializable_object)
    end.to raise_error(Weetbix::UnserializableTypeError)
  end
end
