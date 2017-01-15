require "oj"

module Weetbix
  class JsonSerializer
    def initialize(serializer)
      @serializer = serializer
    end

    def dump(*args)
      Oj.dump(@serializer.dump(*args), mode: :strict)
    end

    def load(json, *args)
      @serializer.load Oj.load(json, mode: :strict), *args
    end
  end
end
