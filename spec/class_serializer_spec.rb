require "spec_helper"

require "weetbix"

module Weetbix
  describe ClassSerializer do
    subject { Weetbix::ClassSerializer.new(::Types, "urn:everydayhero:types:") }

    it "should dump/load types" do
      expect(subject.dump(::Types::Foo)).to eq "urn:everydayhero:types:Foo"
      expect(subject.dump(::Types::Bar)).to eq "urn:everydayhero:types:Bar"

      expect(subject.load("urn:everydayhero:types:Foo")).to eq ::Types::Foo
      expect(subject.load("urn:everydayhero:types:Bar")).to eq ::Types::Bar
    end
  end
end
