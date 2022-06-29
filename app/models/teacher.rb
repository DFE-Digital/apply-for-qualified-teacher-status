# == Schema Information
#
# Table name: teachers
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  email                :string           default(""), not null
#  unconfirmed_email    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#
class Teacher < ApplicationRecord
  devise :magic_link_authenticatable, :confirmable, :registerable, :timeoutable

  validates :email,
            presence: true,
            uniqueness: {
              allow_blank: true,
              case_sensitive: true,
              if: :will_save_change_to_email?
            },
            format: {
              with: Devise.email_regexp,
              allow_blank: true,
              if: :will_save_change_to_email?
            }

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
