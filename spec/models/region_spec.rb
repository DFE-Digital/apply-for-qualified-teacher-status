# == Schema Information
#
# Table name: regions
#
#  id                                            :bigint           not null, primary key
#  application_form_skip_work_history            :boolean          default(FALSE), not null
#  name                                          :string           default(""), not null
#  qualifications_information                    :text             default(""), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  sanction_check                                :string           default("none"), not null
#  status_check                                  :string           default("none"), not null
#  teaching_authority_address                    :text             default(""), not null
#  teaching_authority_certificate                :text             default(""), not null
#  teaching_authority_emails                     :text             default([]), not null, is an Array
#  teaching_authority_name                       :text             default(""), not null
#  teaching_authority_online_checker_url         :string           default(""), not null
#  teaching_authority_other                      :text             default(""), not null
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  teaching_authority_requires_submission_email  :boolean          default(FALSE), not null
#  teaching_authority_sanction_information       :string           default(""), not null
#  teaching_authority_status_information         :string           default(""), not null
#  teaching_authority_websites                   :text             default([]), not null, is an Array
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
  subject(:region) { build(:region, teaching_authority_name:) }

  let(:teaching_authority_name) { "" }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:country_id) }
    it do
      is_expected.to define_enum_for(:sanction_check)
        .with_values(none: "none", online: "online", written: "written")
        .with_prefix(:sanction_check)
        .backed_by_column_of_type(:string)
    end
    it do
      is_expected.to define_enum_for(:status_check)
        .with_values(none: "none", online: "online", written: "written")
        .with_prefix(:status_check)
        .backed_by_column_of_type(:string)
    end
    it do
      is_expected.to validate_url_of(
        :teaching_authority_online_checker_url,
      ).with_message("Enter a valid teaching authority online checker URL")
    end

    context "with a teaching authority name that starts with the" do
      let(:teaching_authority_name) { "the authority" }
      it { is_expected.to_not be_valid }
    end
  end

  describe "scopes" do
    describe "#requires_preliminary_check" do
      subject(:requires_preliminary_check) do
        described_class.requires_preliminary_check
      end

      let!(:normal_region) { create(:region) }
      let!(:preliminary_region) do
        create(
          :region,
          country: create(:country, requires_preliminary_check: true),
        )
      end

      it { is_expected.to_not include(normal_region) }
      it { is_expected.to include(preliminary_region) }
    end
  end

  describe "#teaching_authority_emails_string" do
    subject(:teaching_authority_emails_string) do
      region.teaching_authority_emails_string
    end

    it { is_expected.to eq("") }

    context "when there are emails" do
      before do
        region.update(
          teaching_authority_emails: %w[a@example.com b@example.com],
        )
      end

      it { is_expected.to eq("a@example.com\nb@example.com") }
    end
  end

  describe "#teaching_authority_emails_string=" do
    subject(:teaching_authority_emails) { region.teaching_authority_emails }

    it { is_expected.to eq([]) }

    context "when there are emails" do
      before do
        region.update(
          teaching_authority_emails_string: "a@example.com\nb@example.com\n",
        )
      end

      it { is_expected.to eq(%w[a@example.com b@example.com]) }
    end
  end

  describe "#teaching_authority_websites_string" do
    subject(:teaching_authority_websites_string) do
      region.teaching_authority_websites_string
    end

    it { is_expected.to eq("") }

    context "when there are emails" do
      before do
        region.update(
          teaching_authority_websites: %w[example1.com example2.com],
        )
      end

      it { is_expected.to eq("example1.com\nexample2.com") }
    end
  end

  describe "#teaching_authority_emails_string=" do
    subject(:teaching_authority_websites) { region.teaching_authority_websites }

    it { is_expected.to eq([]) }

    context "when there are emails" do
      before do
        region.update(
          teaching_authority_websites_string: "example1.com\nexample2.com\n",
        )
      end

      it { is_expected.to eq(%w[example1.com example2.com]) }
    end
  end

  describe "#teaching_authority_present?" do
    subject(:teaching_authority_present?) { region.teaching_authority_present? }

    it { is_expected.to eq(false) }

    context "with a name" do
      before { region.update(teaching_authority_name: "Name") }

      it { is_expected.to eq(true) }
    end

    context "with an address" do
      before { region.update(teaching_authority_address: "Address") }

      it { is_expected.to eq(true) }
    end

    context "with an email address" do
      before { region.update(teaching_authority_emails: ["test@example.com"]) }

      it { is_expected.to eq(true) }
    end

    context "with a website" do
      before do
        region.update(teaching_authority_websites: ["https://www.example.com"])
      end

      it { is_expected.to eq(true) }
    end
  end
end
