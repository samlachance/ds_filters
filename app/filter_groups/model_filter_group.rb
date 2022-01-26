class ModelFilterGroup < FilterGroup
  COLUMN = :model

  def initialize(**args)
    super
    self.filter = :model
  end
end
