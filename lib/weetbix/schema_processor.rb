require "weetbix/primitives"

module Weetbix
  class SchemaProcessor
    def initialize(processors, key_transform)
      @processors = processors
      @key_transform = key_transform
    end

    def call(values_hash, schema)
      values_hash.each_with_object({}) do |(k, v), hash|
        schema_type = schema.fetch(k.to_sym)
        hash[@key_transform.call(k)] = process_value(v, schema_type)
      end
    end

    def process_value(value, type)
      if dry_struct?(type)
        call(value, type.schema)
      else
        if dry_primitive?(type)
          process_dry_primitive(value, type)
        elsif dry_sum?(type)
          if dry_sum_ambiguous?(type)
            raise Weetbix::AmbiguousTypeError, "can't dump ambiguous #{type.inspect}"
          else
            dump_value(value)
          end
        elsif dry_enum?(type)
          process_value(value, type.type)
        else
          raise "unknown dry thing: #{type.inspect}"
        end
      end
    end

    def dry_sum_ambiguous?(sum)
      primitives = walk_dry_sum(sum) do |type|
        Primitives.new.json_type(type.primitive)
      end

      primitives.size != primitives.uniq.size
    end

    def walk_dry_sum(obj, &block)
      if dry_sum?(obj)
        walk_dry_sum(obj.left, &block) + walk_dry_sum(obj.right, &block)
      else
        [yield(obj)]
      end
    end

    def process_dry_primitive(value, type)
      primitive = type.type.primitive
      if primitive == Array
        process_dry_array(value, type)
      elsif primitive == Hash
        process_dry_hash(value, type)
      else
        @processors.fetch(primitive).call(value)
      end
    end

    def process_dry_array(values, type)
      member = type.type.options.fetch(:member)
      values.map do |value|
        process_value(value, member)
      end
    end

    def process_dry_hash(hash, _type)
      assert_json_compatible_hash(hash)

      hash
    end

    InvalidJSONHash = Class.new(StandardError)

    def assert_json_compatible_hash(hash)
      raise InvalidJSONHash, "non-string key" unless hash.keys.all? { |k| k.instance_of?(String) }

      hash.each do |_key, value|
        assert_json_compatible_value(value)
      end
    end

    # XXX: a bit loose on JSON numbers
    def assert_json_compatible_value(value)
      case value
      when String, Integer, Float, NilClass, TrueClass, FalseClass
        true
      when Hash
        assert_json_compatible_hash(value)
      when Array
        value.each { |value| assert_json_compatible_value(value) }
      else
        raise InvalidJSONHash, value.class.name
      end
    end

    def dump_value(value)
      primitive = value.class
      @processors.fetch(primitive).call(value)
    end

    def dry_sum?(type)
      type.is_a?(Dry::Types::Sum)
    end

    def dry_enum?(type)
      type.is_a?(Dry::Types::Enum)
    end

    def dry_primitive?(type)
      type.is_a?(Dry::Types::Constrained)
    end

    def dry_struct?(type)
      type.respond_to?(:ancestors) && type.ancestors.include?(Dry::Struct)
    end
  end
end
