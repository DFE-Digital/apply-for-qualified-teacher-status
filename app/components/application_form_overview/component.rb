# frozen_string_literal: true

module ApplicationFormOverview
  class Component < ApplicationComponent
    def initialize(application_form, current_staff:, highlight_email: false)
      super()
      @application_form = application_form
      @current_staff = current_staff
      @highlight_email = highlight_email
    end

    def title
      I18n.t("application_form.overview.title")
    end

    def summary_rows
      application_form_summary_rows(
        application_form,
        current_staff:,
        include_name: true,
        highlight_email:,
      ) +
        [
          {
            key: {
              text: I18n.t("application_form.overview.application_history"),
            },
            value: {
              text:
                govuk_link_to(
                  I18n.t("application_form.overview.view_timeline"),
                  [:timeline, :assessor_interface, application_form],
                ),
            },
          },
        ]
    end

    private

    attr_reader :application_form, :current_staff, :highlight_email

    delegate :application_form_summary_rows, to: :helpers
  end
end
