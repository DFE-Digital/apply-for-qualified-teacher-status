# frozen_string_literal: true

class DocumentContinueRedirection
  include ServicePattern

  def initialize(document:)
    @document = document
  end

  def call
    if document.for_further_information_request?
      further_information_request_url
    else
      send("#{document.document_type}_url")
    end
  end

  private

  attr_reader :document

  def identification_url
    %i[teacher_interface application_form]
  end

  def name_change_url
    %i[check teacher_interface application_form personal_information]
  end

  def qualification_certificate_url
    [
      :edit,
      :teacher_interface,
      :application_form,
      document.documentable.transcript_document,
    ]
  end

  def qualification_transcript_url
    if document.documentable.is_teaching_qualification?
      [
        :part_of_university_degree,
        :teacher_interface,
        :application_form,
        document.documentable,
      ]
    else
      %i[check teacher_interface application_form qualifications]
    end
  end

  def written_statement_url
    %i[teacher_interface application_form]
  end

  def further_information_request_url
    [
      :teacher_interface,
      :application_form,
      document.documentable.further_information_request,
    ]
  end
end
