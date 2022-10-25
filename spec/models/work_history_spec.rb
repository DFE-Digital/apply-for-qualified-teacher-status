# == Schema Information
#
# Table name: work_histories
#
#  id                  :bigint           not null, primary key
#  city                :text             default(""), not null
#  contact_email       :text             default(""), not null
#  contact_name        :text             default(""), not null
#  country_code        :text             default(""), not null
#  end_date            :date
#  job                 :text             default(""), not null
#  school_name         :text             default(""), not null
#  start_date          :date
#  still_employed      :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe WorkHistory, type: :model do
  subject(:work_history) { build(:work_history) }

  describe "validations" do
    it { is_expected.to be_valid }
  end

  describe "#ordered" do
    let(:newest) { create(:work_history, start_date: 1.week.ago) }
    let(:oldest) { create(:work_history, start_date: 1.month.ago) }

    before do
      oldest
      newest
    end

    it "orders in reverse order of start date" do
      expect(described_class.ordered).to eq([newest, oldest])
    end
  end

  describe "#current_or_most_recent_role?" do
    subject(:current_or_most_recent_role?) do
      work_history.current_or_most_recent_role?
    end

    context "when there are no saved work histories" do
      it { is_expected.to eq(true) }
    end

    context "when there are saved work histories and this is the first" do
      before { work_history.save! }

      it { is_expected.to eq(true) }
    end

    context "when there are saved work histories and this is not the first" do
      before do
        create(
          :work_history,
          application_form: work_history.application_form,
          start_date: Date.new(2020, 1, 1),
        )
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "#country_location" do
    subject(:country_location) { work_history.country_location }

    it { is_expected.to be_nil }

    context "with a country code" do
      before { work_history.country_code = "GB-SCT" }

      it { is_expected.to eq("country:GB-SCT") }
    end
  end
end
