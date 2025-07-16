# frozen_string_literal: true

class AssessorInterface::FilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :assessor_ids,
                :date_of_birth,
                :email,
                :location,
                :name,
                :reference,
                :show_all,
                :stage,
                :submitted_at_after,
                :submitted_at_before,
                :statuses,
                :prioritised
end
