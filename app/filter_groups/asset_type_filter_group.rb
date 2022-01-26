class AssetTypeFilterGroup < FilterGroup
  COLUMN = :asset_type_id
  def initialize(**args)
    super
    self.filter = :asset_type_id
  end

  def group_count
    scope.joins(:asset_type).group('mm_asset_types.id', 'mm_asset_types.name').count
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
