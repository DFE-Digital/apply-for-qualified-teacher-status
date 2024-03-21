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
                :stage,
                :submitted_at_after,
                :submitted_at_before,
                :show_all
end
