# frozen_string_literal: true

class AssessorInterface::SortForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :sort_by
end
