require "dry-struct"

module Weetbix
  module DryPredicates
    module_function

    def dry_sum?(type)
      type.is_a?(Dry::Types::Sum)
    end

    def dry_default?(type)
      type.is_a?(Dry::Types::Default)
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
