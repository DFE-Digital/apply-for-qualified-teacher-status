class AssessorInterface::FilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :assessor_ids,
                :location,
                :name,
                :states,
                :submitted_at_before,
                :submitted_at_after
end
