# frozen_string_literal: true

# == Schema Information
#
# Table name: regions
#
#  id                                            :bigint           not null, primary key
#  application_form_skip_work_history            :boolean          default(FALSE), not null
#  name                                          :string           default(""), not null
#  other_information                             :text             default(""), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  requires_preliminary_check                    :boolean          default(FALSE), not null
#  sanction_check                                :string           default("none"), not null
#  sanction_information                          :string           default(""), not null
#  status_check                                  :string           default("none"), not null
#  status_information                            :string           default(""), not null
#  teaching_authority_address                    :text             default(""), not null
#  teaching_authority_certificate                :text             default(""), not null
#  teaching_authority_emails                     :text             default([]), not null, is an Array
#  teaching_authority_name                       :text             default(""), not null
#  teaching_authority_online_checker_url         :string           default(""), not null
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  teaching_authority_requires_submission_email  :boolean          default(FALSE), not null
#  teaching_authority_websites                   :text             default([]), not null, is an Array
#  teaching_qualification_information            :text             default(""), not null
#  written_statement_optional                    :boolean          default(FALSE), not null
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  country_id                                    :bigint           not null
#
# Indexes
#
#  index_regions_on_country_id           (country_id)
#  index_regions_on_country_id_and_name  (country_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
require "rails_helper"

RSpec.describe Region, type: :model do
  subject(:region) { build(:region) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:country_id) }

    it do
      expect(subject).to define_enum_for(:sanction_check)
        .with_values(none: "none", online: "online", written: "written")
        .with_prefix(:sanction_check)
        .backed_by_column_of_type(:string)
    end

    it do
      expect(subject).to define_enum_for(:status_check)
        .with_values(none: "none", online: "online", written: "written")
        .with_prefix(:status_check)
        .backed_by_column_of_type(:string)
    end
  end
end
