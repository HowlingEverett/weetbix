module Weetbix
  class Primitives
    Serializations = {
      String => :string,
      Symbol => :string,
      Integer => :number,
      Float => :number,
      Date => :string,
      DateTime => :string,
      Time => :string,
      TrueClass => :true,
      FalseClass => :false,
      NilClass => :nil,
    }

    def json_type(type)
      Serializations.fetch(type)
    end
  end
end
