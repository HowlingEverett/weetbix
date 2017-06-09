require "weetbix/version"

require "weetbix/dumper"
require "weetbix/loader"
require "weetbix/namespace"
require "weetbix/json_serializer"

module Weetbix
  AmbiguousTypeError = Class.new(StandardError)
  UnserializableTypeError = Class.new(StandardError)

  class Serializer
    def dump(obj)
      Dumper.new.call(obj)
    end

    def load(obj, klass)
      Loader.new.call(obj, klass)
    end
  end

  module_function def serializer(mod, prefix)
    JsonSerializer.new(namespaced(mod, prefix))
  end

  module_function def dump(obj)
    Serializer.new.dump(obj)
  end

  module_function def load(obj, klass)
    Serializer.new.load(obj, klass)
  end

  module_function def namespaced(mod, prefix)
    Namespace.new(Serializer.new, mod, prefix)
  end
end
