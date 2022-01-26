# Problems
# First, the FILTER_GROUP_CLASSES const sucks. I'd almost rather do metaprogramming
# next, the scopes really need to be nailed down. It isn't as refined as it could be
# the COLUMN const and the filter instance var need to be worked out. They seem duped

# class FilterGroup
#   FILTER_GROUP_CLASSES = {
#     model: ::ModelFilterGroup,
#     manufacturer: ::ManufacturerFilterGroup,
#     asset_type_id: ::AssetTypeFilterGroup,
#     asset_category_id: ::AssetCategoryFilterGroup,
#     type_with_specs: ::SpecFilterGroup,
#     sort: ::SortFilterGroup,
#     ownership: ::OwnershipFilterGroup
#   }
# end


class FilterGroup
  attr_accessor :filter, :filter_scope, :initial_scope, :params, :tenant

  # The scoping here needs to be worked out. I think it can be simplified
  def initialize(**args)
    self.filter = args[:filter]
    self.initial_scope = args[:scope]
    self.filter_scope = args[:scope]
    self.params = args[:params]
    self.tenant = args[:tenant]
  end

  # Should this be done using metaprogramming rather than this dictionary
  def self.build_scope(scope, value)
    scope.where(self::COLUMN => value)
  end

  def scope
    scope = filter_scope
    # Build the scope up by calling #build_scope on each of the filter group
    # classes (except the current filter group). We exclude the current filter
    # group so that we get a full set of filter options even if the user has
    # set criteria for the current filter group.
    params.except(filter).each do |param, value|
      scope = FILTER_GROUP_CLASSES[param.to_sym].build_scope(scope, value)
    end
    scope
  end

  def group_count
    scope.group(filter).count
  end

  def generate_options
    group_count.map do |option|
      if option[0]
        {
          value: option[0],
          name: option[0],
          is_selected: !!params[filter]&.include?(option[0].to_s),
          count: option[1],
          type: 'check_box'
        }
      end
    end.compact
  end
end
