# frozen_string_literal: true

# == Schema Information
#
# Table name: english_language_providers
#
#  id                          :bigint           not null, primary key
#  accepted_tests              :string           default(""), not null
#  b2_level_requirement        :text             not null
#  b2_level_requirement_prefix :string           default(""), not null
#  check_url                   :string
#  name                        :string           not null
#  other_information           :text             default(""), not null
#  reference_hint              :text             not null
#  reference_name              :string           not null
#  url                         :string           default(""), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

require "rails_helper"

RSpec.describe EnglishLanguageProvider, type: :model do
  subject(:english_language_provider) { build(:english_language_provider) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:b2_level_requirement_prefix) }
    it { is_expected.to validate_presence_of(:b2_level_requirement) }
    it { is_expected.to validate_presence_of(:reference_name) }
    it { is_expected.to validate_presence_of(:reference_hint) }
    it { is_expected.to validate_url_of(:check_url) }
  end
end
