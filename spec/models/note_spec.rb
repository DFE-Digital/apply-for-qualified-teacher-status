# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id                    :bigint           not null, primary key
#  text                  :text             not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  application_form_id   :bigint
#  author_id             :bigint           not null
#  eligibility_domain_id :bigint
#
# Indexes
#
#  index_notes_on_application_form_id    (application_form_id)
#  index_notes_on_author_id              (author_id)
#  index_notes_on_eligibility_domain_id  (eligibility_domain_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (author_id => staff.id)
#

require "rails_helper"

RSpec.describe Note, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:author) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:text) }
  end
end
