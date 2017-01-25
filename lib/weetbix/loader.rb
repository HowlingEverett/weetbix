require "weetbix/schema_processor"
require "weetbix/types"

module Weetbix
  class Loader
    loader = Weetbix::Types.method(:load)
    Processor = SchemaProcessor.new(loader, :to_sym.to_proc)

    def call(graph, klass)
      klass.new Processor.call(graph, klass.schema)
    end
  end
end
