# frozen_string_literal: true

module ApplicationFormSearchResult
  class Component < ApplicationComponent
    def initialize(
      application_form,
      current_staff:,
      unsuitable:,
      prioritised:,
      on_hold:
    )
      super()
      @application_form = application_form
      @current_staff = current_staff
      @unsuitable = unsuitable
      @prioritised = prioritised
      @on_hold = on_hold
    end

    def full_name
      application_form_full_name(application_form)
    end

    def href
      assessor_interface_application_form_path(application_form)
    end

    def summary_rows
      application_form_summary_rows(
        application_form,
        current_staff:,
        include_name: false,
        include_reviewer: application_form.reviewer.present?,
        class_context: "app-search-result__item",
      )
    end

    attr_reader :unsuitable, :prioritised, :on_hold

    private

    attr_reader :application_form, :current_staff

    delegate :application_form_full_name, to: :helpers
    delegate :application_form_summary_rows, to: :helpers
  end
end
