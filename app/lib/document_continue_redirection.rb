# frozen_string_literal: true

class DocumentContinueRedirection
  include ServicePattern

  def initialize(document:)
    @document = document
  end

  def call
    if document.for_further_information_request?
      further_information_request_url
    elsif document.for_consent_request?
      consent_request_url
    else
      send("#{document.document_type}_url")
    end
  end

  private

  attr_reader :document

  delegate :documentable, to: :document

  def identification_url
    %i[teacher_interface application_form]
  end

  def name_change_url
    %i[check teacher_interface application_form personal_information]
  end

  def medium_of_instruction_url
    %i[check teacher_interface application_form english_language]
  end

  def english_language_proficiency_url
    %i[check teacher_interface application_form english_language]
  end

  def qualification_certificate_url
    [:teacher_interface, :application_form, documentable.transcript_document]
  end

  def qualification_transcript_url
    if documentable.is_teaching_qualification?
      %i[part_of_degree teacher_interface application_form qualifications]
    else
      [:check, :teacher_interface, :application_form, documentable]
    end
  end

  def written_statement_url
    %i[teacher_interface application_form]
  end

  def further_information_request_url
    [
      :teacher_interface,
      :application_form,
      documentable.further_information_request,
    ]
  end

  def consent_request_url
    %i[teacher_interface application_form consent_requests]
  end
end
