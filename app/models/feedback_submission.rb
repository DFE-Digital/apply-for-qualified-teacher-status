# frozen_string_literal: true

# == Schema Information
#
# Table name: feedback_submissions
#
#  id                 :bigint           not null, primary key
#  application_status :string
#  comment            :text
#  overall_experience :string
#  submitted_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class FeedbackSubmission < ApplicationRecord
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
