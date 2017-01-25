require "weetbix/schema_processor"

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
    Processor = SchemaProcessor.new(LOADERS, :to_sym.to_proc)

    def call(graph, klass)
      klass.new Processor.call(graph, klass.schema)
    end
  end
end
