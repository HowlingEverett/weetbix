# rubocop:disable Metrics/MethodLength
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "weetbix"

require "dry-struct"

module Types
  include Dry::Types.module

  Statuses = Types::Strict::String.enum("draft", "published", "archived")

  class Foo < Dry::Struct
    attribute :amount, Types::Strict::Decimal
    attribute :timestamp, Types::Strict::Time
  end

  class StrictTypes < Dry::Struct
    attribute :nil, Types::Strict::Nil
    attribute :symbol, Types::Strict::Symbol
    attribute :true, Types::Strict::True
    attribute :false, Types::Strict::False
    attribute :bool, Types::Strict::Bool
    attribute :date, Types::Strict::Date
    attribute :date_time, Types::Strict::DateTime
    attribute :time, Types::Strict::Time
    attribute :dates, Types::Strict::Array.member(Types::Strict::Date)
    attribute :bools, Types::Strict::Array.member(Types::Strict::Bool)
    attribute :status, Statuses
  end

  class Bar < Dry::Struct
    attribute :foo, Foo
    attribute :strict_types, StrictTypes
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
  end
end

def sample_bar
  foo = Types::Foo.new(
    amount: BigDecimal.new("5"),
    timestamp: Time.utc(2009),
  )
  Types::Bar.new(
    foo: foo,
    strict_types: {
      nil: nil,
      symbol: :symbol,
      true: true,
      false: false,
      bool: false,
      date: Date.new(2017, 1, 1),
      date_time: DateTime.new(2017, 1, 1, 3, 4, 5),
      time: Time.utc(2009),
      dates: [Date.new(2017, 1, 2), Date.new(2017, 1, 3)],
      bools: [true, false, true, false],
      status: "draft",
    },
    lol: "astring",
  )
end

def sample_bar_json
  {
    "foo" => {
      "amount" => "0.5E1",
      "timestamp" => "2009-01-01T00:00:00Z",
    },
    "strict_types" => {
      "nil" => nil,
      "symbol" => "symbol",
      "true" => true,
      "false" => false,
      "bool" => false,
      "date" => "2017-01-01",
      "date_time" => "2017-01-01T03:04:05+00:00",
      "time" => "2009-01-01T00:00:00Z",
      "dates" => ["2017-01-02", "2017-01-03"],
      "bools" => [true, false, true, false],
      "status" => "draft",
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
