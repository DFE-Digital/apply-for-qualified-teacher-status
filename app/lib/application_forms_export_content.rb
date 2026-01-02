# frozen_string_literal: true

class ApplicationFormsExportContent
  class << self
    def csv_headers
      %w[
        reference
        country_trained_in
        submitted_at
        assigned_to
        reviewer
        given_names
        family_name
        alternative_given_names
        alternative_family_name
        date_of_birth
        statuses
        stage
        prioritised
        awarded_at
        declined_at
        withdrawn_at
      ]
    end

    def csv_row(application_form)
      [
        "\"#{application_form.reference}\"",
        CountryName.from_code(application_form.country.code),
        application_form.submitted_at.to_date,
        application_form.assessor&.name,
        application_form.reviewer&.name,
        application_form.given_names,
        application_form.family_name,
        application_form.alternative_given_names,
        application_form.alternative_family_name,
        application_form.date_of_birth,
        human_readable_statuses(application_form.statuses).join(", "),
        human_readable_stage(application_form.stage),
        application_form.assessment.prioritised,
        application_form.awarded_at&.to_date,
        application_form.declined_at&.to_date,
        application_form.withdrawn_at&.to_date,
      ]
    end

    def human_readable_statuses(statuses)
      statuses.map { |status| I18n.t("components.status_tag.#{status}") }
    end

    def human_readable_stage(stage)
      I18n.t("components.status_tag.#{stage}")
    end
  end
end
