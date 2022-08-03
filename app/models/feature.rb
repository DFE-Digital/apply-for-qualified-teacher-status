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
class Feature < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
