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
    current_staff:,
    include_name:,
    include_reviewer: true,
    highlight_email: false,
    class_context: nil
  )
    [
      (
        if include_name
          {
            key: {
              text: I18n.t("application_form.summary.name"),
            },
            value: {
              text: application_form_full_name(application_form),
            },
            actions: [
              if AssessorInterface::ApplicationFormPolicy.new(
                   current_staff,
                   application_form,
                 ).edit?
                {
                  visually_hidden_text: I18n.t("application_form.summary.name"),
                  href: [:edit, :assessor_interface, application_form],
                }
              end,
            ].compact,
          }
        end
      ),
      {
        key: {
          text: I18n.t("application_form.summary.country"),
        },
        value: {
          text: CountryName.from_country(application_form.region.country),
        },
      },
      (
        if application_form.region.name.present?
          {
            key: {
              text: I18n.t("application_form.summary.region"),
            },
            value: {
              text: application_form.region.name,
            },
          }
        end
      ),
      {
        key: {
          text: I18n.t("application_form.summary.email"),
        },
        value: {
          text:
            (
              if highlight_email
                "<em class=\"app-highlight\">#{ERB::Util.html_escape(application_form.teacher.email)}</em>".html_safe
              else
                application_form.teacher.email
              end
            ),
        },
      },
      {
        key: {
          text: I18n.t("application_form.summary.submitted_at"),
        },
        value: {
          text: application_form.submitted_at.strftime("%e %B %Y"),
        },
      },
      {
        key: {
          text: I18n.t("application_form.summary.days_since_submission"),
        },
        value: {
          text:
            pluralize(application_form.working_days_since_submission, "day"),
        },
      },
      {
        key: {
          text: I18n.t("application_form.summary.assessor"),
        },
        value: {
          text:
            application_form.assessor&.name ||
              I18n.t("application_form.summary.unassigned"),
        },
        actions: [
          {
            visually_hidden_text: I18n.t("application_form.summary.assessor"),
            href: [:assessor_interface, application_form, :assign_assessor],
          },
        ],
      },
      (
        if include_reviewer
          {
            key: {
              text: I18n.t("application_form.summary.reviewer"),
            },
            value: {
              text:
                application_form.reviewer&.name ||
                  I18n.t("application_form.summary.unassigned"),
            },
            actions: [
              {
                visually_hidden_text:
                  I18n.t("application_form.summary.reviewer"),
                href: [:assessor_interface, application_form, :assign_reviewer],
              },
            ],
          }
        end
      ),
      {
        key: {
          text: I18n.t("application_form.summary.reference"),
        },
        value: {
          text: application_form.reference,
        },
      },
      {
        key: {
          text: I18n.t("application_form.summary.status"),
        },
        value: {
          text:
            render(
              StatusTag::Component.new(
                application_form.statuses,
                class_context:,
              ),
            ),
        },
      },
    ].compact
  end
end
