require "weetbix/schema_processor"
require "hashie"

module Weetbix
  identity = -> (v) { v }

  LOADERS = {
    BigDecimal => BigDecimal.method(:new),
    Time => Time.method(:xmlschema),
    Date => Date.method(:xmlschema),
    DateTime => DateTime.method(:xmlschema),
    String => identity,
    NilClass => identity,
    TrueClass => identity,
    FalseClass => identity,
    Symbol => :to_sym.to_proc,
  }

  class Loader
    Processor = SchemaProcessor.new(LOADERS)

    def call(graph, klass)
      klass.new Processor.call(Hashie.symbolize_keys(graph), klass.schema)
    end
  end
end
