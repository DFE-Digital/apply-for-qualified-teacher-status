# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_failure_reasons_work_histories
#
#  assessor_feedback          :text
#  selected_failure_reason_id :bigint           not null
#  work_history_id            :bigint           not null
#
class SelectedFailureReasonsWorkHistory < ApplicationRecord
  belongs_to :selected_failure_reason
  belongs_to :work_history
end
