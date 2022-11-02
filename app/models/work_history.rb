# == Schema Information
#
# Table name: work_histories
#
#  id                  :bigint           not null, primary key
#  city                :text             default(""), not null
#  contact_email       :text             default(""), not null
#  contact_name        :text             default(""), not null
#  country_code        :text             default(""), not null
#  end_date            :date
#  job                 :text             default(""), not null
#  school_name         :text             default(""), not null
#  start_date          :date
#  still_employed      :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
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
  include ApplicationFormStatusUpdatable

  belongs_to :application_form

  scope :ordered, -> { order(start_date: :desc, created_at: :desc) }

  def current_or_most_recent_role?
    application_form.work_histories.empty? ||
      application_form.work_histories.ordered.first == self
  end

  def country_name
    CountryName.from_code(country_code)
  end
end
