# frozen_string_literal: true

class ConsentLetter
  include ApplicationFormHelper

  def initialize(application_form:)
    @application_form = application_form
    @date_of_consent = application_form.submitted_at.to_date
  end

  def render_pdf
    document.render
  end

  private

  attr_reader :application_form, :date_of_consent

  MARGIN = 62
  LINE_PAD = 12
  SECTION_PAD = 48

  PRIVACY_URL =
    "https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/5a254207-a566-44f7-ac77-6ba59fd26e04#using-your-data-when-you-use-the-apply-for-qualified-teacher-status-qts-in-england-service"

  def document
    @document ||=
      Prawn::Document
        .new(margin: MARGIN)
        .tap do |pdf|
          # rubocop:disable Rails/SaveBang
          pdf.font_families.update(
            "Open Sans" => {
              normal: "public/open-sans.ttf",
            },
          )
          # rubocop:enable Rails/SaveBang

          pdf.font "Open Sans"

          pdf.image(
            "public/dfe-logo-master-portrait-white.png",
            position: :right,
            scale: 0.6,
          )

          pdf.pad(SECTION_PAD) do
            pdf.text "By submitting an application to the Apply for qualified teacher status (QTS) in England."

            pdf.pad(LINE_PAD) do
              pdf.text "I have given consent for my data to be shared with organisations that can confirm " \
                         "teaching qualifications or professional standing as a teacher."
            end

            pdf.text "I hereby authorise and request all parties to release information on my academic " \
                       "standing/records to the Department for Education for the purpose of verification in accordance with UK GDPR."
          end

          pdf.text "Name: #{application_form_full_name(application_form)}"

          pdf.pad(LINE_PAD * 2) do
            pdf.text "Date of birth: #{application_form.date_of_birth.to_fs}"
          end

          pdf.text "Date of consent: #{date_of_consent.to_fs}"

          pdf.pad(SECTION_PAD) do
            pdf.pad_top(LINE_PAD) do
              pdf.text "The full privacy statement can be found " \
                         "<link href='#{PRIVACY_URL}'><u><color rgb='0000EE'>here</color></u></link>.",
                       inline_format: true
            end
          end
        end
  end
end
