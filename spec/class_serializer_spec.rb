require "spec_helper"

require "weetbix"

describe Weetbix do
  it "should dump/load types" do
    subject = Weetbix::ClassSerializer.new(Types, "urn:everydayhero:types:")

    expect(subject.dump(Types::Foo)).to eq "urn:everydayhero:types:Foo"
    expect(subject.dump(Types::Bar)).to eq "urn:everydayhero:types:Bar"

    expect(subject.load("urn:everydayhero:types:Foo")).to eq Types::Foo
    expect(subject.load("urn:everydayhero:types:Bar")).to eq Types::Bar
  end
end
