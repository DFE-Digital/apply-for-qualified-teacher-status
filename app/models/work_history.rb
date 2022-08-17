# == Schema Information
#
# Table name: work_histories
#
#  id                  :bigint           not null, primary key
#  city                :text             default(""), not null
#  country_code        :text             default(""), not null
#  email               :text             default(""), not null
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
  belongs_to :application_form

  validates :email, valid_for_notify: true, allow_blank: true
  validates :end_date, presence: true, allow_nil: true, unless: :still_employed?

  scope :completed,
        -> {
          where
            .not(school_name: "", city: "", country: "", job: "", email: "")
            .where.not(start_date: nil)
            .where(still_employed: true)
            .or(where(still_employed: false).where.not(end_date: nil))
        }

  scope :ordered, -> { order(start_date: :asc, created_at: :asc) }

  def status
    values = [
      school_name,
      city,
      country,
      job,
      email,
      start_date,
      still_employed
    ]

    if still_employed == false
      values.pop
      values.append(end_date)
    end

    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end

  def current_or_most_recent_role?
    application_form.work_histories.empty? ||
      application_form.work_histories.ordered.first == self
  end
end
