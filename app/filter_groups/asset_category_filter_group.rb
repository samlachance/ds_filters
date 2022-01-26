class AssetCategoryFilterGroup < FilterGroup
  # Don't think I need this technically
  COLUMN = :asset_category_id
  def initialize(**args)
    super
    self.filter = :asset_category_id
    self.filter_scope = initial_scope.joins(:asset_type)
  end

  def self.build_scope(scope, value)
    scope.joins(:asset_type).where(mm_asset_types: { asset_category_id: value })
  end

  def group_count
    scope.joins(asset_type: :asset_category).group('mm_asset_categories.id', 'mm_asset_categories.name').count
  end

  def generate_options
    group_count.map do |option|
      if option[0]
        {
          value: option[0][0],
          name: option[0][1],
          is_selected: !!params[filter]&.include?(option[0][0].to_s),
          count: option[1],
          type: 'check_box'
        }
      end
    end.compact
  end
end
