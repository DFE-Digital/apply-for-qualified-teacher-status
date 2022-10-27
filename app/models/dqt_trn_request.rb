# == Schema Information
#
# Table name: dqt_trn_requests
#
#  id                  :bigint           not null, primary key
#  state               :string           default("pending"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  request_id          :uuid             not null
#
# Indexes
#
#  index_dqt_trn_requests_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class DQTTRNRequest < ApplicationRecord
  belongs_to :application_form

  enum :state,
       { initial: "initial", pending: "pending", complete: "complete" },
       default: :initial
  validates :state, presence: true, inclusion: { in: states.values }

  def update_from_dqt_response(response)
    if (trn = response[:trn]).present?
      application_form.teacher.update!(trn:)
      complete!
    else
      pending!
    end
  end
end
