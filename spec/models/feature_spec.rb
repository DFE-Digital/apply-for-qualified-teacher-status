require "rails_helper"

RSpec.describe Feature, type: :model do
  subject { described_class.new(name: :basic_auth) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
