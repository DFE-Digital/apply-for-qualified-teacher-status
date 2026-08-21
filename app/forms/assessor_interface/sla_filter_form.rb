# frozen_string_literal: true

class AssessorInterface::SLAFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :breach_statuses, :country_groupings, :prioritised, :sla
end
