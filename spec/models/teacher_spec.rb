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
