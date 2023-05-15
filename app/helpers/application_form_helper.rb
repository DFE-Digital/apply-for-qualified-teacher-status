# frozen_string_literal: true

module ApplicationFormHelper
  def application_form_full_name(application_form)
    if application_form.given_names.present? ||
         application_form.family_name.present?
      "#{application_form.given_names} #{application_form.family_name}".strip
    else
      "applicant"
    end
  end

  def application_form_summary_rows(
    application_form,
    include_name:,
    include_reference:,
    include_reviewer: true,
    highlight_email: false
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
      [
        I18n.t("application_form.summary.email"),
        (
          if highlight_email
            "<em class=\"app-highlight\">#{ERB::Util.html_escape(application_form.teacher.email)}</em>".html_safe
          else
            application_form.teacher.email
          end
        ),
      ],
      (
        if application_form.region.name.present?
          [
            I18n.t("application_form.summary.region"),
            application_form.region.name,
          ]
        end
      ),
      [
        I18n.t("application_form.summary.submitted_at"),
        application_form.submitted_at.strftime("%e %B %Y"),
      ],
      [
        I18n.t("application_form.summary.days_since_submission"),
        pluralize(application_form.working_days_since_submission, "day"),
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
      (
        if include_reviewer
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
          ]
        end
      ),
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
          StatusTag::Component.new(
            key: "application-form-#{application_form.id}",
            status: application_form.status,
            class_context: "app-search-result__item",
          ),
        ),
      ],
    ].compact.map do |key, value, actions|
      { key: { text: key }, value: { text: value }, actions: actions || [] }
    end
  end
end
