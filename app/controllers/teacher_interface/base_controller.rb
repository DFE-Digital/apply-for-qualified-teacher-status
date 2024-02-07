# frozen_string_literal: true

class TeacherInterface::BaseController < ApplicationController
  include TeacherCurrentNamespace

  before_action :authenticate_teacher!

  def load_application_form
    @application_form = application_form
  end

  def load_document
    @document = document
  end

  def application_form
    @application_form ||= current_teacher.application_form
  end

  def document
    @document ||=
      Document.where(
        documentable:
          [application_form] + application_form.qualifications +
            (
              application_form
                .assessment
                &.further_information_requests
                &.flat_map(&:items) || []
            ) + (application_form.assessment&.qualification_requests || []),
      ).find(params[:document_id] || params[:id])
  end

  def redirect_unless_application_form_is_draft
    if application_form.nil? || application_form.submitted?
      redirect_to %i[teacher_interface application_form]
    end
  end

  def redirect_unless_draft_or_additional_information
    if document.for_further_information_request?
      unless document.documentable.further_information_request.requested?
        redirect_to %i[teacher_interface application_form]
      end
    elsif document.for_qualification_request?
      if document.documentable.consent_requested_at.nil? ||
           document.documentable.consent_received_at.present?
        redirect_to %i[teacher_interface application_form]
      end
    else
      redirect_unless_application_form_is_draft
    end
  end
end
