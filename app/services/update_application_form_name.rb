# frozen_string_literal: true

class UpdateApplicationFormName
  include ServicePattern

  def initialize(application_form:, user:, given_names: nil, family_name: nil)
    @application_form = application_form
    @user = user
    @given_names = given_names
    @family_name = family_name
  end

  def call
    ActiveRecord::Base.transaction do
      change_value("given_names", given_names)
      change_value("family_name", family_name)
    end
  end

  private

  attr_reader :application_form, :user, :given_names, :family_name

  def change_value(column_name, new_value)
    return if new_value.blank?

    old_value = application_form.send(column_name)
    return if new_value == old_value

    application_form.update!(column_name => new_value)

    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      column_name:,
      old_value:,
      new_value:,
    )
  end
end
