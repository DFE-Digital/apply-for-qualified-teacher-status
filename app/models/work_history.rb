# frozen_string_literal: true

# == Schema Information
#
# Table name: work_histories
#
#  id                      :bigint           not null, primary key
#  canonical_contact_email :text             default(""), not null
#  city                    :text             default(""), not null
#  contact_email           :text             default(""), not null
#  contact_job             :string           default(""), not null
#  contact_name            :text             default(""), not null
#  country_code            :text             default(""), not null
#  end_date                :date
#  end_date_is_estimate    :boolean          default(FALSE), not null
#  hours_per_week          :integer
#  job                     :text             default(""), not null
#  school_name             :text             default(""), not null
#  start_date              :date
#  start_date_is_estimate  :boolean          default(FALSE), not null
#  still_employed          :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  application_form_id     :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id      (application_form_id)
#  index_work_histories_on_canonical_contact_email  (canonical_contact_email)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class WorkHistory < ApplicationRecord
  belongs_to :application_form
  has_one :reference_request, required: false
  has_and_belongs_to_many :selected_failure_reasons
  has_one :further_information_request_item,
          required: false,
          dependent: :destroy

  scope :order_by_role, -> { order(start_date: :desc) }
  scope :order_by_user, -> { order(created_at: :asc) }

  def current_or_most_recent_role?
    application_form.work_histories.empty? ||
      application_form.work_histories.order_by_role.first == self
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
    values = [school_name, city, country_code, job, start_date, still_employed]

    if still_employed == false
      values.pop
      values.append(end_date)
    end

    unless application_form.reduced_evidence_accepted?
      values += [contact_name, contact_email]
    end

    if application_form.created_under_new_regulations?
      values.append(hours_per_week)

      unless application_form.reduced_evidence_accepted?
        values.append(contact_job)
      end
    end

    values.all?(&:present?)
  end

  def incomplete?
    !complete?
  end
end
