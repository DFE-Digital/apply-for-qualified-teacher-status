# frozen_string_literal: true

# == Schema Information
#
# Table name: english_language_providers
#
#  id                   :bigint           not null, primary key
#  b2_level_requirement :text             not null
#  check_url            :string
#  name                 :string           not null
#  reference_hint       :text             not null
#  reference_name       :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class EnglishLanguageProvider < ApplicationRecord
  validates :name, presence: true
  validates :b2_level_requirement, presence: true
  validates :reference_name, presence: true
  validates :reference_hint, presence: true
  validates :check_url, url: true, allow_blank: true
end
