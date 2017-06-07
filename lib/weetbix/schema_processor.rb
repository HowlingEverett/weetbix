require "weetbix/types"

module Weetbix
  class SchemaProcessor
    def initialize(processor, key_transform)
      @processor = processor
      @key_transform = key_transform
    end

    def call(values_hash, schema)
      values_hash.each_with_object({}) do |(k, v), hash|
        schema_type = schema.fetch(k.to_sym)
        hash[@key_transform.call(k)] = process_value(v, schema_type)
      end
    rescue InvalidJSONHash
      raise UnserializableTypeError
    end

    private

    RULES = {
      dry_struct?: :process_dry_struct,
      dry_primitive?: :process_dry_primitive,
      dry_sum?: :process_dry_sum,
      dry_enum?: :process_dry_enum,
    }

    def process_value(value, type)
      RULES.each do |predicate, action|
        return send(action, value, type) if send(predicate, type)
      end

      raise "unknown dry thing: #{type.inspect}"
    end

    def dry_sum_ambiguous?(sum)
      primitives = walk_dry_sum(sum) do |type|
        Types.json_type(type.primitive)
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

    def process_dry_struct(value, type)
      call(value, type.schema)
    end

    def process_dry_primitive(value, type)
      primitive = type.type.primitive
      if primitive == Array
        process_dry_array(value, type)
      elsif primitive == Hash
        process_dry_hash(value, type)
      else
        serialize_primitive(primitive, value)
      end
    end

    def process_dry_sum(value, type)
      if dry_sum_ambiguous?(type)
        raise AmbiguousTypeError, "can't dump ambiguous #{type.inspect}"
      end

      serialize_primitive(value.class, value)
    end

    def process_dry_enum(value, type)
      process_value(value, type.type)
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
      unless hash.keys.all? { |k| k.instance_of?(String) }
        raise InvalidJSONHash, "non-string key"
      end

      hash.each do |_key, value|
        assert_json_compatible_value(value)
      end
    end

    def assert_json_compatible_value(value)
      case value
      # NOTE: JSON numbers can technically include very big integers
      when String, Integer, Float, NilClass, TrueClass, FalseClass
        true
      when Hash
        assert_json_compatible_hash(value)
      when Array
        value.each { |obj| assert_json_compatible_value(obj) }
      else
        raise InvalidJSONHash, value.class.name
      end
    end

    def serialize_primitive(type, value)
      @processor.call(type, value)
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
