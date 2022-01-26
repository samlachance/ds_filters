class SpecFilterGroup < FilterGroup
  COLUMN = :type_with_specs
  attr_accessor :specs_payload
  def initialize(**args)
    super
    self.filter = :type_with_specs

    # This can be improved -- ugly
    if specs_json = self.params['type_with_specs']
      self.specs_payload = JSON.parse(specs_json)['specs']
    end
  end

  def self.build_scope(scope, value)
    # This temp disables the spec criteria from being considered in other filter
    # group scopes. Need to figure out how the specs criteria should affect other
    # filter groups
    scope
  end

  def specs
    if params[:asset_type_id]&.size == 1
      MMSpecification
        .joins(:asset_type, asset_specifications: :asset)
        .includes(:asset_specifications)
        .where(mm_asset_types: {id: params[:asset_type_id], tenant_id: tenant.id})
        .merge(scope)
        .order(:position)
        .uniq
    else
      []
    end
  end

  def parse_spec_type(spec)
    return 'range' if spec.is_numeric
    return 'select' if spec.options.any?
  end

  def generate_options
    # raise specs.to_s if specs.size > 0
    specs.map do |spec|
      type = parse_spec_type(spec)
      # start_filter = !!params[filter]
      # end_filter = !!params[filter]
      start_filter, end_filter, selected_option = nil

      # FIXME: Just added the `selected_option` attribute. I feel that this is growing
      # unwieldy.
      if specs_payload.present?
        # FIXME: There is a problem here when we are comparing IDs.
        # I hate the to_i stuff. I also had to add in the hash that's returned
        # Also, having the & on the values seems bad. The upstream problem is that all fields
        # are being sent even if no value was input
        case type
        when 'range'
          start_filter, end_filter = specs_payload.find {|s| s['spec_id'].to_i == spec.id}&.[]('values')
        when 'select'
          selected_option = specs_payload.find {|s| s['spec_id'].to_i == spec.id}&.[]('values')[0]
        end
      end

      # FIXME: The unit is probably not handled how it should be.
      # #first is being used for PoC but we should refine the behavior
      # soon.

      # FIXME: Having the `text` attribute doesn't feel right. It seems like we
      # need to list all of the potential options which I have done in `options`
      # just not sure why I chose to make a text attribute. Possibly a mistake
      {
        id: spec.id,
        value: spec.name,
        name: spec.name,
        type: type,
        min: spec.asset_specifications.minimum(:numeric),
        max: spec.asset_specifications.maximum(:numeric),
        text: spec.asset_specifications.pluck(:text).compact,
        unit: spec.asset_specifications.pluck(:unit).compact.first,
        start_filter: start_filter.to_i,
        end_filter: end_filter.to_i,
        options: spec.asset_specifications.pluck(:text).uniq.compact,
        selected_option: selected_option
      }
    end
  end
end
