module ApplicationFormOverview
  class Component < ViewComponent::Base
    def initialize(application_form)
      super
      @application_form = application_form
    end

    def title
      I18n.t("application_form.overview.title")
    end

    def summary_rows
      application_form_summary_rows(
        application_form,
        include_name: true,
        include_reference: true,
        include_notes: false
      ) +
        [
          {
            key: {
              text: I18n.t("application_form.overview.application_history")
            },
            value: {
              text:
                govuk_link_to(
                  I18n.t("application_form.overview.view_timeline"),
                  assessor_interface_application_form_timeline_events_path(
                    application_form
                  )
                )
            }
          }
        ]
    end

    private

    attr_reader :application_form

    delegate :application_form_summary_rows, to: :helpers
  end
end
