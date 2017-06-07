require "weetbix/schema_processor"
require "hashie"

module Weetbix
  identity = -> (v) { v }
  unserializable = -> (v) { raise UnserializableTypeError, v.class.name }

  DUMPERS = {
    BigDecimal => :to_s.to_proc,
    Time => :xmlschema.to_proc,
    Date => :xmlschema.to_proc,
    DateTime => :xmlschema.to_proc,
    String => identity,
    NilClass => identity,
    TrueClass => identity,
    FalseClass => identity,
    Symbol => :to_s.to_proc,
    # TODO: loader?
    Class => unserializable,
  }

  class Dumper
    Processor = SchemaProcessor.new(DUMPERS)

    def call(obj)
      Hashie.stringify_keys Processor.call(obj.to_hash, obj.class.schema)
    rescue KeyError => e
      raise "missing dumper (#{e.message})"
    end
  end
end
