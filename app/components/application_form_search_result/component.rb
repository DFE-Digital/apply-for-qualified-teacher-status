module ApplicationFormSearchResult
  class Component < ViewComponent::Base
    def initialize(application_form:, search_params:)
      super
      @application_form = application_form
      @search_params = search_params
    end

    def full_name
      application_form_full_name(application_form)
    end

    def href
      assessor_interface_application_form_path(
        application_form,
        search: search_params
      )
    end

    def summary_rows
      application_form_summary_rows(
        application_form,
        include_name: false,
        include_reference: false,
        include_notes: true
      )
    end

    private

    attr_reader :application_form, :search_params

    delegate :application_form_full_name, to: :helpers
    delegate :application_form_summary_rows, to: :helpers
  end
end
