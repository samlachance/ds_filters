class OwnershipFilterGroup < FilterGroup
  COLUMN = :ownership

  def initialize(**args)
    super
    self.filter = :ownership
  end

  def generate_options
    []
  end
end
