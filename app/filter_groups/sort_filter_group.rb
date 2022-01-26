class SortFilterGroup < FilterGroup
  BASE_SORT_OPTIONS = [
    {name: 'manufacturer', value: 'manufacturer'},
    {name: 'model', value: 'model'},
    {name: 'created_at', value: 'created_at'},
    {name: 'updated_at', value: 'updated_at'},
  ]

  def self.build_scope(scope, value)
    # Return base scope since the sort param only affects order
    scope
  end

  def generate_options
    sort_options = BASE_SORT_OPTIONS.clone

    if params[:asset_type_id]&.size == 1
      specs = MMSpecification
        .joins(:asset_type)
        .where(is_numeric: true, mm_asset_types: { id: params[:asset_type_id], tenant_id: tenant.id})
        .uniq

      specs.each do |spec|
        sort_options << {name: spec.name, value: "spec:#{spec.id}"}
      end
    end

    sort_options.inject([]) do |acc, sort_option|
      %w(asc desc).each do |direction|
        option_value = "#{sort_option[:value]}.#{direction}"
        option = {
          name: sort_option[:name],
          value: option_value,
          is_selected: params[:sort] == option_value
        }

        acc << option
      end

      acc
    end
  end
end
