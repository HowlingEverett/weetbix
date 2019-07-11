# rubocop:disable Metrics/MethodLength
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "weetbix"

module Types
  include Dry.Types()

  Statuses = Types::Strict::String.enum("draft", "published", "archived")

  class Foo < Dry::Struct
    attribute :amount, Types::Strict::Decimal
    attribute :timestamp, Types::Strict::Time
  end

  class StrictTypes < Dry::Struct
    attribute :nil, Types::Strict::Nil
    attribute :symbol, Types::Strict::Symbol.optional.default(nil)
    attribute :true, Types::Strict::True.optional.default(nil)
    attribute :false, Types::Strict::False.optional.default(nil)
    attribute :bool, Types::Strict::Bool.optional.default(nil)
    attribute :date, Types::Strict::Date.optional.default(nil)
    attribute :date_time, Types::Strict::DateTime.optional.default(nil)
    attribute :time, Types::Strict::Time.optional.default(nil)
    attribute :maybe_string, Types::Strict::String.optional.default(nil)
    attribute :maybe_not_string, Types::Strict::String.optional.default(nil)
    attribute :dates, Types::Strict::Array.of(Types::Strict::Date)
    attribute :bools, Types::Strict::Array.of(Types::Strict::Bool)
    attribute :status, Statuses
    attribute :primitive_hash, Types::Strict::Hash.optional.default(nil)
  end

  class Bar < Dry::Struct
    attribute :foo, Foo
    attribute :maybe_foo, Foo.optional
    attribute :strict_types, StrictTypes.optional
    attribute :lol, Types::Strict::String
  end

  module Unserializable
    class ClassType < Dry::Struct
      attribute :klass, Types::Strict::Class
    end

    class AmbiguousType < Dry::Struct
      attribute :ambiguous, (
        Types::Strict::String |
        Types::Strict::Symbol |
        Types::Strict::Int
      )
    end

    # Not unserializable if we stick to primitives
    class HashType < Dry::Struct
      attribute :hash, Types::Strict::Hash
    end
  end
end

def sample_bar
  foo = Types::Foo.new(
    amount: BigDecimal.new("5"),
    timestamp: Time.utc(2009),
  )
  Types::Bar.new(
    foo: foo,
    maybe_foo: nil,
    strict_types: {
      nil: nil,
      symbol: :symbol,
      true: true,
      false: false,
      bool: false,
      date: Date.new(2017, 1, 1),
      date_time: DateTime.new(2017, 1, 1, 3, 4, 5),
      time: Time.utc(2009),
      maybe_string: "maybe",
      maybe_not_string: nil,
      dates: [Date.new(2017, 1, 2), Date.new(2017, 1, 3)],
      bools: [true, false, true, false],
      status: "draft",
      primitive_hash: {
        "foo" => "bar",
        "baz" => "quux",
        "xyzzy" => 1,
        "plugh" => nil,
      },
    },
    lol: "astring",
  )
end

def sample_bar_json
  {
    "foo" => {
      "amount" => "5.0",
      "timestamp" => "2009-01-01T00:00:00Z",
    },
    "maybe_foo" => nil,
    "strict_types" => {
      "nil" => nil,
      "symbol" => "symbol",
      "true" => true,
      "false" => false,
      "bool" => false,
      "date" => "2017-01-01",
      "date_time" => "2017-01-01T03:04:05+00:00",
      "time" => "2009-01-01T00:00:00Z",
      "maybe_string" => "maybe",
      "maybe_not_string" => nil,
      "dates" => ["2017-01-02", "2017-01-03"],
      "bools" => [true, false, true, false],
      "status" => "draft",
      "primitive_hash" => {
        "foo" => "bar",
        "baz" => "quux",
        "xyzzy" => 1,
        "plugh" => nil,
      },
    },
    "lol" => "astring",
  }
end

def sample_bar_json_with_type(type)
  {
    "@type" => type,
  }.merge(sample_bar_json)
end

def sample_ambiguous
  Types::Unserializable::AmbiguousType.new(ambiguous: "test")
end

def sample_unserializable
  Types::Unserializable::ClassType.new(klass: String)
end

def sample_unserializable_hash
  Types::Unserializable::HashType.new(hash: {symbol_keys: "no"})
end
