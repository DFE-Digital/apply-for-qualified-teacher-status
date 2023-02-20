# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_response               :boolean
#  dates_response                  :boolean
#  hours_response                  :boolean
#  lessons_response                :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_response                :boolean
#  reviewed_at                     :datetime
#  slug                            :string           not null
#  state                           :string           not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  assessment_id                   :bigint           not null
#  work_history_id                 :bigint           not null
#
# Indexes
#
#  index_reference_requests_on_assessment_id    (assessment_id)
#  index_reference_requests_on_slug             (slug) UNIQUE
#  index_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
class ReferenceRequest < ApplicationRecord
  include Requestable
  include Reviewable

  has_secure_token :slug

  belongs_to :work_history

  with_options if: :received? do
    validates :dates_response, inclusion: [true, false]
    validates :hours_response, inclusion: [true, false]
    validates :children_response, inclusion: [true, false]
    validates :lessons_response, inclusion: [true, false]
    validates :reports_response, inclusion: [true, false]
  end

  delegate :application_form, to: :assessment

  def responses_given?
    responses.none?(&:nil?)
  end

  def responses_valid?
    responses.all?(&:present?)
  end

  def expires_after
    6.weeks
  end

  def after_reviewed(*)
    UpdateAssessmentInductionRequired.call(assessment:)
  end

  private

  def responses
    [
      dates_response,
      hours_response,
      children_response,
      lessons_response,
      reports_response,
    ]
  end
end
