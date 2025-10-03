# frozen_string_literal: true

# == Schema Information
#
# Table name: eligibility_domains
#
#  id                      :bigint           not null, primary key
#  application_forms_count :integer          default(0)
#  archived_at             :datetime
#  domain                  :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  created_by_id           :bigint           not null
#
# Indexes
#
#  index_eligibility_domains_on_created_by_id  (created_by_id)
#  index_eligibility_domains_on_domain         (domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => staff.id)
#

require "rails_helper"

RSpec.describe EligibilityDomain, type: :model do
  let(:eligibility_domain) { build :eligibility_domain }

  describe "#active?" do
    subject(:active?) { eligibility_domain.active? }

    context "when no archived_at is set on the record" do
      it { is_expected.to be true }
    end

    context "when archived_at is set on the record" do
      before { eligibility_domain.archived_at = Time.current }

      it { is_expected.to be false }
    end
  end
end
