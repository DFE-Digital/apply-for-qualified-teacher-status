# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_failure_reasons_work_histories
#
#  id                         :bigint           not null, primary key
#  assessor_feedback          :text
#  selected_failure_reason_id :bigint           not null
#  work_history_id            :bigint           not null
#
# Indexes
#
#  idx_on_selected_failure_reason_id_work_history_id_2013815cea  (selected_failure_reason_id,work_history_id) UNIQUE
#
class SelectedFailureReasonsWorkHistory < ApplicationRecord
  belongs_to :selected_failure_reason
  belongs_to :work_history
end
