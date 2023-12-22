# frozen_string_literal: true

class ConsentLetter
  include ApplicationFormHelper

  def initialize(qualification_request:)
    @qualification_request = qualification_request
  end

  def render_pdf
    document.render
  end

  private

  attr_reader :qualification_request

  delegate :application_form, to: :qualification_request

  def document
    @document ||=
      Prawn::Document.new.tap do |pdf|
        pdf.text "By submitting an application to the Apply for qualified teacher status (QTS) in England."
        pdf.text "I have given consent for my data to be shared with organisations that can confirm teaching " \
                   "qualifications or professional standing as a teacher."
        pdf.text "I hereby authorise and request all parties to release information on my academic standing/records " \
                   "to the TRA for the purpose of verification in accordance with UK GDPR."

        pdf.pad(30) do
          pdf.text "Name: #{application_form_full_name(application_form)}"
          pdf.text "Date of birth: #{application_form.date_of_birth.to_fs(:long_ordinal_uk)}"
          pdf.text "Date of consent: #{qualification_request.created_at.to_fs(:long_ordinal_uk)}"
        end

        pdf.text "The service is run by the Teaching Regulation Agency (TRA) an executive agency of the Department " \
                   "for Education (DfE)."
        pdf.text "The full privacy statement can be found " \
                   "<link href='https://apply-for-qts-in-england.education.gov.uk/privacy'>here</link>.",
                 inline_format: true
      end
  end
end
