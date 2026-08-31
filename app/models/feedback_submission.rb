# frozen_string_literal: true

# == Schema Information
#
# Table name: feedback_submissions
#
#  id                  :bigint           not null, primary key
#  application_status  :string           not null
#  comment             :text
#  overall_experience  :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint
#  teacher_id          :bigint
#
# Indexes
#
#  index_feedback_submissions_on_application_form_id  (application_form_id)
#  index_feedback_submissions_on_teacher_id           (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
class FeedbackSubmission < ApplicationRecord
  belongs_to :teacher, optional: true
  belongs_to :application_form, optional: true

  enum :application_status,
       {
         not_started: "not_started",
         submitting_an_application: "submitting_an_application",
         application_submitted: "application_submitted",
         confirmed_qts: "confirmed_qts",
         unsuccessful: "unsuccessful",
         not_an_applicant: "not_an_applicant",
       },
       prefix: true

  enum :overall_experience,
       {
         highly_satisfied: "highly_satisfied",
         somewhat_satisfied: "somewhat_satisfied",
         neither_satisfied_nor_dissatisfied:
           "neither_satisfied_nor_dissatisfied",
         dissatisfied: "dissatisfied",
         very_dissatisfied: "very_dissatisfied",
       },
       prefix: true
end
