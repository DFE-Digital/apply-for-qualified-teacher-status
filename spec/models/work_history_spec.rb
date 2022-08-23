# == Schema Information
#
# Table name: work_histories
#
#  id                  :bigint           not null, primary key
#  city                :text             default(""), not null
#  country_code        :text             default(""), not null
#  email               :text             default(""), not null
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
RSpec.describe WorkHistory, type: :model do
  subject(:work_history) { build(:work_history) }

  describe "validations" do
    it { is_expected.to be_valid }

    context "when not still employed" do
      before { work_history.still_employed = false }
      it { is_expected.to validate_presence_of(:end_date).allow_nil }
    end
  end

  describe "#completed" do
    let!(:incomplete_work_history) { create(:work_history) }
    let!(:complete_work_history) { create(:work_history, :completed) }

    subject(:completed) { described_class.completed }

    it { is_expected.to match_array([complete_work_history]) }
  end

  describe "#status" do
    subject(:status) { work_history.status }

    it { is_expected.to eq(:not_started) }

    context "when partially filled out" do
      before { work_history.update!(country_code: "FR") }

      it { is_expected.to eq(:in_progress) }
    end

    context "when fully filled out and still employed" do
      before do
        work_history.update!(
          school_name: "School",
          city: "City",
          country_code: "FR",
          job: "Job",
          email: "school@example.com",
          start_date: Date.new(2020, 1, 1),
          still_employed: true
        )
      end

      it { is_expected.to eq(:completed) }
    end

    context "when fully filled out and not still employed" do
      before do
        work_history.update!(
          school_name: "School",
          city: "City",
          country_code: "FR",
          job: "Job",
          email: "school@example.com",
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2020, 12, 1),
          still_employed: false
        )
      end

      it { is_expected.to eq(:completed) }
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
          start_date: Date.new(2020, 1, 1)
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
