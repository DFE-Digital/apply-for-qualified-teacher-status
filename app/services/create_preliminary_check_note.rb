# frozen_string_literal: true

class CreatePreliminaryCheckNote < CreateNote
  include ServicePattern

  def initialize(application_form:, author: nil)
    @application_form = application_form
    @author = author || Staff.find_by(support_console_permission: true)

    super(application_form:, author: @author, text:)
  end

  def call
    return unless requires_preliminary_check?

    super
  end

  private

  attr_reader :application_form, :author
  delegate :assessment, :region, to: :application_form

  def text
    if assessment.preliminary_check_complete.nil?
      I18n.t(
        "assessor_interface.case_notes.preliminary_check.application_submitted",
      )
    elsif awaiting_professional_standing?
      I18n.t(
        "assessor_interface.case_notes.preliminary_check.complete_waiting_for_professional_standing",
      )
    else
      I18n.t("assessor_interface.case_notes.preliminary_check.complete")
    end
  end

  def awaiting_professional_standing?
    assessment.professional_standing_request&.requested?
  end

  def requires_preliminary_check?
    region.requires_preliminary_check ||
      region.country.requires_preliminary_check
  end
end
