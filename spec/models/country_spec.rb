# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id                                 :bigint           not null, primary key
#  code                               :string           not null
#  eligibility_enabled                :boolean          default(TRUE), not null
#  eligibility_skip_questions         :boolean          default(FALSE), not null
#  other_information                  :text             default(""), not null
#  sanction_information               :string           default(""), not null
#  status_information                 :string           default(""), not null
#  subject_limited                    :boolean          default(FALSE), not null
#  teaching_qualification_information :text             default(""), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  subject(:country) { build(:country) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_inclusion_of(:code).in_array(%w[GB-SCT FR]) }
    it { is_expected.not_to validate_inclusion_of(:code).in_array(%w[ABC]) }
  end
end
