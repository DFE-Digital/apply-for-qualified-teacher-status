# frozen_string_literal: true

module PageObjects
  class NewFeedbackSubmission < SitePrism::Page
    set_url "/feedback/new"

    element :heading, "h1"

    section :form, "form" do
      element :not_started_application_status_radio_item,
              "#feedback-submission-form-application-status-not-started-field",
              visible: false
      element :submitting_an_application_application_status_radio_item,
              "#feedback-submission-form-application-status-submitting-an-application-field",
              visible: false
      element :application_submitted_application_status_radio_item,
              "#feedback-submission-form-application-status-application-submitted-field",
              visible: false
      element :confirmed_qts_application_status_radio_item,
              "#feedback-submission-form-application-status-confirmed-qts-field",
              visible: false
      element :unsuccessful_application_status_radio_item,
              "#feedback-submission-form-application-status-unsuccessful-field",
              visible: false
      element :not_an_applicant_application_status_radio_item,
              "#feedback-submission-form-application-status-not-an-applicant-field",
              visible: false

      element :highly_satisfied_overall_experience_radio_item,
              "#feedback-submission-form-overall-experience-highly-satisfied-field",
              visible: false
      element :somewhat_satisfied_overall_experience_radio_item,
              "#feedback-submission-form-overall-experience-somewhat-satisfied-field",
              visible: false
      element :neither_satisfied_nor_dissatisfied_overall_experience_radio_item,
              "#feedback-submission-form-overall-experience-neither-satisfied-nor-dissatisfied-field",
              visible: false
      element :dissatisfied_overall_experience_radio_item,
              "#feedback-submission-form-overall-experience-dissatisfied-field",
              visible: false
      element :very_dissatisfied_overall_experience_radio_item,
              "#feedback-submission-form-overall-experience-very-dissatisfied-field",
              visible: false

      element :comment_textarea, "#feedback-submission-form-comment-field"

      element :submit_button, "button.govuk-button"
    end
  end
end
