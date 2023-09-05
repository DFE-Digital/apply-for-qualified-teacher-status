# == Schema Information
#
# Table name: countries
#
#  id                                    :bigint           not null, primary key
#  code                                  :string           not null
#  eligibility_enabled                   :boolean          default(TRUE), not null
#  eligibility_skip_questions            :boolean          default(FALSE), not null
#  other_information                     :text             default(""), not null
#  qualifications_information            :text             default(""), not null
#  sanction_information                  :string           default(""), not null
#  status_information                    :string           default(""), not null
#  teaching_authority_address            :text             default(""), not null
#  teaching_authority_certificate        :text             default(""), not null
#  teaching_authority_emails             :text             default([]), not null, is an Array
#  teaching_authority_name               :text             default(""), not null
#  teaching_authority_online_checker_url :string           default(""), not null
#  teaching_authority_websites           :text             default([]), not null, is an Array
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  subject(:country) { build(:country, teaching_authority_name:) }

  let(:teaching_authority_name) { "" }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_inclusion_of(:code).in_array(%w[GB-SCT FR]) }
    it { is_expected.to_not validate_inclusion_of(:code).in_array(%w[ABC]) }
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

  describe "#teaching_authority_emails_string" do
    subject(:teaching_authority_emails_string) do
      country.teaching_authority_emails_string
    end

    it { is_expected.to eq("") }

    context "when there are emails" do
      before do
        country.update(
          teaching_authority_emails: %w[a@example.com b@example.com],
        )
      end

      it { is_expected.to eq("a@example.com\nb@example.com") }
    end
  end

  describe "#teaching_authority_emails_string=" do
    subject(:teaching_authority_emails) { country.teaching_authority_emails }

    it { is_expected.to eq([]) }

    context "when there are emails" do
      before do
        country.update(
          teaching_authority_emails_string: "a@example.com\nb@example.com\n",
        )
      end

      it { is_expected.to eq(%w[a@example.com b@example.com]) }
    end
  end

  describe "#teaching_authority_websites_string" do
    subject(:teaching_authority_websites_string) do
      country.teaching_authority_websites_string
    end

    it { is_expected.to eq("") }

    context "when there are emails" do
      before do
        country.update(
          teaching_authority_websites: %w[example1.com example2.com],
        )
      end

      it { is_expected.to eq("example1.com\nexample2.com") }
    end
  end

  describe "#teaching_authority_emails_string=" do
    subject(:teaching_authority_websites) do
      country.teaching_authority_websites
    end

    it { is_expected.to eq([]) }

    context "when there are emails" do
      before do
        country.update(
          teaching_authority_websites_string: "example1.com\nexample2.com\n",
        )
      end

      it { is_expected.to eq(%w[example1.com example2.com]) }
    end
  end

  describe "#teaching_authority_present?" do
    subject(:teaching_authority_present?) do
      country.teaching_authority_present?
    end

    it { is_expected.to eq(false) }

    context "with a name" do
      before { country.update(teaching_authority_name: "Name") }

      it { is_expected.to eq(true) }
    end

    context "with an address" do
      before { country.update(teaching_authority_address: "Address") }

      it { is_expected.to eq(true) }
    end

    context "with an email address" do
      before { country.update(teaching_authority_emails: ["test@example.com"]) }

      it { is_expected.to eq(true) }
    end

    context "with a website" do
      before do
        country.update(teaching_authority_websites: ["https://www.example.com"])
      end

      it { is_expected.to eq(true) }
    end
  end
end
