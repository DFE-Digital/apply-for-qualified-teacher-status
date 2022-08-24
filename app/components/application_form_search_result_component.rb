class ApplicationFormSearchResultComponent < ViewComponent::Base
  def initialize(application_form)
    super
    @application_form = application_form
  end

  def full_name
    application_form_full_name(application_form)
  end

  def href
    assessor_interface_application_form_path(application_form)
  end

  def summary_rows
    application_form_summary_rows(application_form)
  end

  private

  attr_reader :application_form

  delegate :application_form_full_name, to: :helpers
  delegate :application_form_summary_rows, to: :helpers
end
