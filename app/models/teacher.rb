# == Schema Information
#
# Table name: teachers
#
#  id                                      :bigint           not null, primary key
#  access_your_teaching_qualifications_url :string
#  canonical_email                         :text             default(""), not null
#  current_sign_in_at                      :datetime
#  current_sign_in_ip                      :string
#  email                                   :string           default(""), not null
#  last_sign_in_at                         :datetime
#  last_sign_in_ip                         :string
#  sign_in_count                           :integer          default(0), not null
#  trn                                     :string
#  uuid                                    :uuid             not null
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#
# Indexes
#
#  index_teacher_on_lower_email       (lower((email)::text)) UNIQUE
#  index_teachers_on_canonical_email  (canonical_email)
#  index_teachers_on_uuid             (uuid) UNIQUE
#
class Teacher < ApplicationRecord
  include Emailable

  devise :magic_link_authenticatable, :registerable, :timeoutable, :trackable

  self.timeout_in = 1.hour

  has_many :application_forms

  before_create { self.canonical_email = EmailAddress.canonical(email) }

  def application_form
    @application_form ||=
      application_forms.not_withdrawn.order(created_at: :desc).first
  end

  def send_magic_link(*)
    token = Devise::Passwordless::LoginToken.encode(self)
    send_devise_notification(:magic_link, token, {})
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
