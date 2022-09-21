module ApplicationFormHelper
  def application_form_full_name(application_form)
    "#{application_form.given_names} #{application_form.family_name}"
  end

  def application_form_summary_rows(
    application_form,
    include_name:,
    include_reference:,
    include_notes:
  )
    [
      (
        if include_name
          [
            I18n.t("application_form.summary.name"),
            application_form_full_name(application_form),
          ]
        end
      ),
      [
        I18n.t("application_form.summary.country"),
        CountryName.from_country(application_form.region.country),
      ],
      [I18n.t("application_form.summary.region"), application_form.region.name],
      [
        I18n.t("application_form.summary.submitted_at"),
        application_form.submitted_at.strftime("%e %B %Y"),
      ],
      [
        I18n.t("application_form.summary.days_remaining_sla"),
        "Not implemented",
      ],
      [
        I18n.t("application_form.summary.assessor"),
        application_form.assessor&.name ||
          I18n.t("application_form.summary.unassigned"),
        [
          {
            href:
              assessor_interface_application_form_assign_assessor_path(
                application_form,
              ),
          },
        ],
      ],
      [
        I18n.t("application_form.summary.reviewer"),
        application_form.reviewer&.name ||
          I18n.t("application_form.summary.unassigned"),
        [
          {
            href:
              assessor_interface_application_form_assign_reviewer_path(
                application_form,
              ),
          },
        ],
      ],
      (
        if include_reference
          [
            I18n.t("application_form.summary.reference"),
            application_form.reference,
          ]
        end
      ),
      [
        I18n.t("application_form.summary.status"),
        render(
          ApplicationFormStatusTag::Component.new(
            key: "application-form-#{application_form.id}",
            status: application_form.state,
            class_context: "app-search-result__item",
          ),
        ),
      ],
      (
        if include_notes
          [I18n.t("application_form.summary.notes"), "Not implemented"]
        end
      ),
    ].compact.map do |key, value, actions|
      { key: { text: key }, value: { text: value }, actions: actions || [] }
    end
  end
end
