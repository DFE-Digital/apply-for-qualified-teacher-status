# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_comment                :text             default(""), not null
#  children_response               :boolean
#  contact_comment                 :text             default(""), not null
#  contact_job                     :string           default(""), not null
#  contact_name                    :string           default(""), not null
#  contact_response                :boolean
#  dates_comment                   :text             default(""), not null
#  dates_response                  :boolean
#  failure_assessor_note           :string           default(""), not null
#  hours_comment                   :text             default(""), not null
#  hours_response                  :boolean
#  lessons_comment                 :text             default(""), not null
#  lessons_response                :boolean
#  misconduct_comment              :text             default(""), not null
#  misconduct_response             :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_comment                 :text             default(""), not null
#  reports_response                :boolean
#  reviewed_at                     :datetime
#  satisfied_comment               :text             default(""), not null
#  satisfied_response              :boolean
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

  has_secure_token :slug

  belongs_to :work_history
  has_many :reminder_emails, as: :remindable

  with_options if: :received? do
    validates :contact_response, inclusion: [true, false]
    validates :dates_response, inclusion: [true, false]
    validates :hours_response, inclusion: [true, false]
    validates :children_response, inclusion: [true, false]
    validates :lessons_response, inclusion: [true, false]
    validates :reports_response, inclusion: [true, false]
    validates :misconduct_response, inclusion: [true, false]
    validates :satisfied_response, inclusion: [true, false]
  end

  delegate :application_form, to: :assessment

  def responses_given?
    [
      contact_response,
      dates_response,
      hours_response,
      children_response,
      lessons_response,
      reports_response,
      misconduct_response,
      satisfied_response,
    ].none?(&:nil?)
  end

  def expires_after
    6.weeks
  end

  def after_reviewed(*)
    UpdateAssessmentInductionRequired.call(assessment:)
  end
end
