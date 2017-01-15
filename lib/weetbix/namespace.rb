require "weetbix/class_serializer"

module Weetbix
  class Namespace
    def initialize(serializer, mod, prefix)
      @serializer = serializer
      @class_serializer = ClassSerializer.new(mod, prefix)
    end

    def dump(obj)
      {
        "@type" => dump_class(obj.class),
      }.merge(@serializer.dump(obj))
    end

    def load(graph)
      type = graph.delete("@type")
      @serializer.load(graph, load_class(type))
    end

    private

    def dump_class(klass)
      @class_serializer.dump(klass)
    end

    def load_class(str)
      @class_serializer.load(str)
    end
  end
end
