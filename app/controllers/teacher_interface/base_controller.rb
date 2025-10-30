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
            ) + (application_form.assessment&.consent_requests || []),
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
    elsif document.for_consent_request?
      if !document.documentable.requested? || document.documentable.received?
        redirect_to %i[teacher_interface application_form]
      end
    else
      redirect_unless_application_form_is_draft
    end
  end

  def transform_date_attribute_values_whitespace(params, *date_attributes)
    params
      .to_h
      .each_with_object({}) do |(key, value), object|
        is_date_attribute =
          date_attributes.any? do |date_attribute|
            key.match?(date_attribute.to_s)
          end

        object[key] = (is_date_attribute ? value.gsub(/\s/, "") : value)
      end
  end
end
