# frozen_string_literal: true

class AssessorInterface::DraftApplicationFormsIndexViewObject
  include Pagy::Backend

  def initialize(params:, session:)
    @params = params
    @session = session
  end

  def application_forms_pagy
    application_forms_with_pagy.first
  end

  def application_forms_records
    application_forms_with_pagy.last
  end

  def filter_form
    @filter_form ||=
      AssessorInterface::DraftApplicationFormsFilterForm.new(filter_params)
  end

  def active_search?
    filter_form.email.present?
  end

  def summary_rows(application_form)
    view_object =
      AssessorInterface::DraftApplicationFormViewObject.new(application_form:)

    [
      [:name, view_object.name],
      [:country, CountryName.from_country(application_form.region.country)],
      [:started_at, application_form.created_at.to_date.to_fs],
      [:days_until_deletion, view_object.days_until_deletion],
    ].map do |key, value|
      {
        key: {
          text:
            I18n.t(
              key,
              scope: %i[
                assessor_interface
                draft_application_forms
                index
                summary
              ],
            ),
        },
        value: {
          text: value,
        },
      }
    end
  end

  private

  attr_reader :params, :session

  def filter_params
    (session[:draft_filter_params] || {}).with_indifferent_access
  end

  def application_forms_with_pagy
    @application_forms_with_pagy ||=
      pagy(
        ::Filters::Email.apply(
          scope:
            ApplicationForm
              .draft_stage
              .includes(:teacher, region: :country)
              .order(created_at: :desc, id: :desc),
          params: filter_params,
        ),
      )
  end
end
