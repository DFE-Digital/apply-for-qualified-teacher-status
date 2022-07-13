# == Schema Information
#
# Table name: application_forms
#
#  id                   :bigint           not null, primary key
#  reference            :string(31)       not null
#  status               :string           default("active"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eligibility_check_id :bigint           not null
#  teacher_id           :bigint           not null
#
# Indexes
#
#  index_application_forms_on_eligibility_check_id  (eligibility_check_id)
#  index_application_forms_on_reference             (reference) UNIQUE
#  index_application_forms_on_status                (status)
#  index_application_forms_on_teacher_id            (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (eligibility_check_id => eligibility_checks.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
class ApplicationForm < ApplicationRecord
  include DfE::Analytics::Entities

  belongs_to :teacher
  belongs_to :eligibility_check

  validates :reference, presence: true, uniqueness: true, length: 3..31

  enum status: { active: "active", submitted: "submitted" }

  before_validation :assign_reference, on: :create

  def assign_reference
    return if reference
    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE"
    )
    self.reference = (ApplicationForm.maximum(:reference) || "2000000").to_i + 1
  end
end
