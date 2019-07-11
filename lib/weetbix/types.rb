require "bigdecimal"
require "time"
require "date"

module Weetbix
  module Types
    Type = Struct.new(:type, :to, :dump, :load)

    def self.serialize(type, to:, dump:, load:)
      # TODO: raise if to isn't a JSON primitive
      @types ||= {}
      @types[type] = Type.new(type, to, dump, load)
    end

    def self.primitive(type, to:)
      identity = ->(v) { v }
      serialize type, to: to, dump: identity, load: identity
    end

    def self.unserializable(type)
      unserializable = ->(v) { raise UnserializableTypeError, v.class.name }
      serialize type, to: :null, dump: unserializable, load: unserializable
    end

    def self.json_type(type)
      if DryPredicates.dry_struct?(type)
        :hash
      else
        @types.fetch(type).to
      end
    end

    def self.dump(type, value)
      @types.fetch(type).dump[value]
    end

    def self.load(type, value)
      @types.fetch(type).load[value]
    end

    primitive String, to: :string
    primitive NilClass, to: :null
    primitive FalseClass, to: :false # rubocop:disable Lint/BooleanSymbol
    primitive TrueClass, to: :true # rubocop:disable Lint/BooleanSymbol

    primitive Integer, to: :number
    primitive Float, to: :number

    primitive Hash, to: :hash

    serialize BigDecimal,
              to: :string,
              dump: ->(num) { num.to_s("F") },
              load: BigDecimal.method(:new)
    serialize Time,
              to: :string,
              dump: :xmlschema.to_proc,
              load: Time.method(:xmlschema)
    serialize Date,
              to: :string,
              dump: :xmlschema.to_proc,
              load: Date.method(:xmlschema)
    serialize DateTime,
              to: :string,
              dump: :xmlschema.to_proc,
              load: DateTime.method(:xmlschema)
    serialize Symbol,
              to: :string,
              dump: :to_s.to_proc,
              load: :to_sym.to_proc

    unserializable Class
  end
end
