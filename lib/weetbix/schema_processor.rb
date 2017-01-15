require "weetbix/primitives"

module Weetbix
  class SchemaProcessor
    def initialize(processors)
      @processors = processors
    end

    def call(values_hash, schema)
      values_hash.each_with_object({}) do |(k, v), hash|
        schema_type = schema.fetch(k)
        hash[k] = process_value(v, schema_type)
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
      @processors.fetch(primitive).call(value)
    end

    def dump_value(value)
      primitive = value.class
      @processors.fetch(primitive).call(value)
    end

    def dry_sum?(type)
      type.is_a?(Dry::Types::Sum)
    end

    def dry_primitive?(type)
      type.is_a?(Dry::Types::Constrained)
    end

    def dry_struct?(type)
      type.respond_to?(:ancestors) && type.ancestors.include?(Dry::Struct)
    end
  end
end
