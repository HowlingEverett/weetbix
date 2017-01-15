module Weetbix
  class ClassSerializer
    def initialize(mod, prefix)
      @mod = mod
      @prefix = prefix
    end

    def dump(klass)
      str = klass.name.sub(/^#{@mod.name}::/, "")
      @prefix + str
    end

    def load(str)
      str = str.sub(/^#{@prefix}/, "")
      @mod.const_get(str)
    end
  end
end
