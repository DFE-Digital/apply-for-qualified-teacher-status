class DescriptionListComponent < ViewComponent::Base
  def initialize(rows:, classes: [])
    super
    @rows = rows
    @classes = classes
  end

  def classes
    ["app-description-list"] + @classes
  end

  attr_reader :rows
end
