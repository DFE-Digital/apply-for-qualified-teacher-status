# == Schema Information
#
# Table name: regions
#
#  id                               :bigint           not null, primary key
#  legacy                           :boolean          default(TRUE), not null
#  name                             :string           default(""), not null
#  sanction_check                   :string           default("none"), not null
#  status_check                     :string           default("none"), not null
#  teaching_authority_address       :text             default(""), not null
#  teaching_authority_certificate   :text             default(""), not null
#  teaching_authority_email_address :text             default(""), not null
#  teaching_authority_other         :text             default(""), not null
#  teaching_authority_website       :text             default(""), not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  country_id                       :bigint           not null
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
      is_expected.to_not validate_presence_of(:teaching_authority_certificate)
    end

    context "with written checks" do
      before do
        allow(region).to receive(:status_check_written?).and_return(true)
      end
      it do
        is_expected.to validate_presence_of(:teaching_authority_certificate)
      end
    end
  end

  describe "#full_name" do
    subject(:full_name) { region.full_name }

    let(:country) { create(:country, code: "GB-SCT") }

    context "with a region" do
      let(:region) { create(:region, country:, name: "Edinburgh") }

      it { is_expected.to eq("Scotland — Edinburgh") }
    end

    context "with a nameless region" do
      let(:region) { create(:region, :national, country:) }

      it { is_expected.to eq("Scotland") }
    end
  end
end
