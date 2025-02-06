# frozen_string_literal: true

class TeacherInterface::PersonalInformationViewObject
  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  def alternative_name_legend
    if requires_passport_as_identity_proof?
      I18n.t(
        "helpers.legend.teacher_interface_alternative_name_form.has_alternative_name_passport",
      )
    else
      I18n.t(
        "helpers.legend.teacher_interface_alternative_name_form.has_alternative_name_id_documents",
      )
    end
  end

  def alternative_name_hint
    if requires_passport_as_identity_proof?
      I18n.t(
        "helpers.hint.teacher_interface_alternative_name_form.has_alternative_name_passport",
      )
    else
      I18n.t(
        "helpers.hint.teacher_interface_alternative_name_form.has_alternative_name_id_documents",
      )
    end
  end

  private

  def requires_passport_as_identity_proof?
    application_form.requires_passport_as_identity_proof
  end
end
