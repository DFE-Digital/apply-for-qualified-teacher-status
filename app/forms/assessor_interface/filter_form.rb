# frozen_string_literal: true

class AssessorInterface::FilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :action_required_by,
                :assessor_ids,
                :email,
                :location,
                :name,
                :reference,
                :statuses,
                :submitted_at_after,
                :submitted_at_before
end
