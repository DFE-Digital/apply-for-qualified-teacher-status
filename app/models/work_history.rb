# == Schema Information
#
# Table name: work_histories
#
#  id                     :bigint           not null, primary key
#  city                   :text             default(""), not null
#  contact_email          :text             default(""), not null
#  contact_job            :string           default(""), not null
#  contact_name           :text             default(""), not null
#  country_code           :text             default(""), not null
#  end_date               :date
#  end_date_is_estimate   :boolean          default(FALSE), not null
#  hours_per_week         :integer
#  job                    :text             default(""), not null
#  school_name            :text             default(""), not null
#  start_date             :date
#  start_date_is_estimate :boolean          default(FALSE), not null
#  still_employed         :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  application_form_id    :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class WorkHistory < ApplicationRecord
  belongs_to :application_form

  scope :ordered, -> { order(created_at: :asc) }

  def current_or_most_recent_role?
    application_form.work_histories.empty? ||
      application_form.work_histories.ordered.first == self
  end

  def locale_key
    if current_or_most_recent_role?
      "current_or_most_recent_role"
    else
      "previous_role"
    end
  end

  def country_name
    CountryName.from_code(country_code)
  end

  def complete?
    values = [
      school_name,
      city,
      country_code,
      job,
      contact_name,
      contact_email,
      start_date,
      still_employed,
    ]

    if still_employed == false
      values.pop
      values.append(end_date)
    end

    if FeatureFlags::FeatureFlag.active?(:application_work_history)
      values += [hours_per_week, contact_job]
    end

    values.all?(&:present?)
  end

  def incomplete?
    !complete?
  end
end
