# == Schema Information
#
# Table name: features
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(FALSE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_features_on_name  (name) UNIQUE
#
RSpec.describe Feature, type: :model do
  subject { described_class.new(name: :basic_auth) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
