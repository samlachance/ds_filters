class ManufacturerFilterGroup < FilterGroup
  COLUMN = :manufacturer
  def initialize(**args)
    super
    self.filter = :manufacturer
  end
end
