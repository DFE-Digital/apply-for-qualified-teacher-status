# frozen_string_literal: true

class AssessorInterface::DraftApplicationFormViewObject
  include ActionView::Helpers::TextHelper

  def initialize(application_form:)
    @application_form = application_form
  end

  def name
    [application_form.given_names, application_form.family_name].reject(
      &:blank?
    )
      .join(" ")
      .presence || "Not provided"
  end

  def days_until_deletion
    pluralize([application_form.days_until_expired, 0].max, "day")
  end

  def summary_rows
    [
      [I18n.t("application_form.summary.name"), name],
      [
        I18n.t("application_form.summary.country"),
        CountryName.from_country(application_form.region.country),
      ],
      [
        I18n.t("application_form.summary.email"),
        application_form.teacher.email,
      ],
      [
        I18n.t("application_form.summary.gov_uk_one_login"),
        application_form.teacher.gov_one_id.present? ? "Linked" : "Unlinked",
      ],
      [
        I18n.t("application_form.summary.draft_created"),
        application_form.created_at.to_date.to_fs,
      ],
      [
        I18n.t("application_form.summary.days_until_deletion"),
        days_until_deletion,
      ],
      [
        I18n.t("application_form.summary.reference"),
        application_form.reference,
      ],
    ].map { |key, value| { key: { text: key }, value: { text: value } } }
  end

  private

  attr_reader :application_form
end
