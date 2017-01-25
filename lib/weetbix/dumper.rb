require "weetbix/schema_processor"
require "weetbix/types"

module Weetbix
  class Dumper
    dumper = Weetbix::Types.method(:dump)
    Processor = SchemaProcessor.new(dumper, :to_s.to_proc)

    def call(obj)
      Processor.call(obj.to_hash, obj.class.schema)
    rescue KeyError => e
      raise "missing dumper (#{e.message})"
    end
  end
end
