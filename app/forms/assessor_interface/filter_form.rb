class AssessorInterface::FilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :assessor_ids, :location, :name, :states
end
