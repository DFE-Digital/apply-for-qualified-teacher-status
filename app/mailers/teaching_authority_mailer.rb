# frozen_string_literal: true

class TeachingAuthorityMailer < ApplicationMailer
  include ApplicationFormHelper

  before_action :set_application_form, :set_qualification, :set_region

  helper :application_form, :qualification, :region

  def application_submitted
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: region.teaching_authority_emails,
      subject:
        I18n.t(
          "mailer.teaching_authority.application_submitted.subject",
          name: application_form_full_name(application_form),
        ),
    )
  end

  private

  def application_form
    params[:application_form]
  end

  delegate :region, to: :application_form

  def set_application_form
    @application_form = application_form
  end

  def set_qualification
    @qualification = application_form.teaching_qualification
  end

  def set_region
    @region = application_form.region
  end
end
