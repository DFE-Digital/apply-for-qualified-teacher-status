# == Schema Information
#
# Table name: teachers
#
#  id                 :bigint           not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  otp_created_at     :datetime
#  otp_guesses        :integer          default(0), not null
#  secret_key         :string
#  sign_in_count      :integer          default(0), not null
#  trn                :string
#  uuid               :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#  index_teachers_on_uuid   (uuid) UNIQUE
#
require "rails_helper"

RSpec.describe Teacher, type: :model do
  subject(:teacher) { create(:teacher) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:email) }
    it do
      is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity
    end
  end
end
