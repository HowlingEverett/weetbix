require "dry-struct"

module Weetbix
  module DryPredicates
    module_function def dry_sum?(type)
      type.is_a?(Dry::Types::Sum)
    end

    module_function def dry_enum?(type)
      type.is_a?(Dry::Types::Enum)
    end

    module_function def dry_primitive?(type)
      type.is_a?(Dry::Types::Constrained)
    end

    module_function def dry_struct?(type)
      type.respond_to?(:ancestors) && type.ancestors.include?(Dry::Struct)
    end
  end
end
