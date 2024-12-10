# frozen_string_literal: true

class DestroyApplicationForm
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    ActiveRecord::Base.transaction do
      timeline_events.destroy_all
      dqt_trn_request&.destroy!
      trs_trn_request&.destroy!
      assessment&.destroy!
      application_form.destroy!
      teacher.destroy! unless teacher.application_forms.exists?
    end
  end

  private

  attr_reader :application_form

  delegate :assessment,
           :teacher,
           :timeline_events,
           :dqt_trn_request,
           :trs_trn_request,
           to: :application_form
end
