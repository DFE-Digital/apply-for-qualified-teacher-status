# frozen_string_literal: true

class ChangeFurtherInformationRequestAssessmentId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :further_information_requests, :assessment_id, false
  end
end
