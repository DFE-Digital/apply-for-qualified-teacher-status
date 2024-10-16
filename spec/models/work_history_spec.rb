# frozen_string_literal: true

# == Schema Information
#
# Table name: work_histories
#
#  id                      :bigint           not null, primary key
#  canonical_contact_email :text             default(""), not null
#  city                    :text             default(""), not null
#  contact_email           :text             default(""), not null
#  contact_email_domain    :text             default(""), not null
#  contact_job             :string           default(""), not null
#  contact_name            :text             default(""), not null
#  country_code            :text             default(""), not null
#  end_date                :date
#  end_date_is_estimate    :boolean          default(FALSE), not null
#  hours_per_week          :integer
#  job                     :text             default(""), not null
#  school_name             :text             default(""), not null
#  start_date              :date
#  start_date_is_estimate  :boolean          default(FALSE), not null
#  still_employed          :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  application_form_id     :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id      (application_form_id)
#  index_work_histories_on_canonical_contact_email  (canonical_contact_email)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe WorkHistory, type: :model do
  subject(:work_history) { create(:work_history) }

  describe "validations" do
    it { is_expected.to be_valid }
  end

  describe "#order_by_role" do
    subject(:order_by_role) { described_class.order_by_role }

    let!(:newest) { create(:work_history, start_date: 1.week.ago) }
    let!(:oldest) { create(:work_history, start_date: 1.month.ago) }

    it { is_expected.to eq([newest, oldest]) }
  end

  describe "#order_by_user" do
    subject(:order_by_user) { described_class.order_by_user }

    let!(:newest) { create(:work_history, created_at: 1.week.ago) }
    let!(:oldest) { create(:work_history, created_at: 1.month.ago) }

    it { is_expected.to eq([oldest, newest]) }
  end

  describe "#current_or_most_recent_role?" do
    subject(:current_or_most_recent_role?) do
      work_history.current_or_most_recent_role?
    end

    let(:work_history) { build(:work_history) }

    context "when there are no saved work histories" do
      it { is_expected.to be(true) }
    end

    context "when there are saved work histories and this is the first" do
      before { work_history.save! }

      it { is_expected.to be(true) }
    end

    context "when there are saved work histories and this is not the first" do
      before do
        create(
          :work_history,
          application_form: work_history.application_form,
          start_date: Date.new(2020, 1, 1),
        )
      end

      it { is_expected.to be(false) }
    end
  end

  describe "#complete?" do
    subject(:complete?) { work_history.complete? }

    it { is_expected.to be false }

    context "with a partially complete qualification" do
      before { work_history.update!(school_name: "School name") }

      it { is_expected.to be false }
    end

    context "with a complete qualification" do
      let(:work_history) { create(:work_history, :completed) }

      it { is_expected.to be true }
    end

    context "without contact information" do
      let(:application_form) { create(:application_form) }

      let(:work_history) do
        build(
          :work_history,
          :completed,
          application_form:,
          contact_name: "",
          contact_job: "",
          contact_email: "",
        )
      end

      it { is_expected.to be false }

      context "with a reduced evidence application form" do
        let(:application_form) do
          create(:application_form, reduced_evidence_accepted: true)
        end

        it { is_expected.to be true }
      end
    end

    context "without a valid contact email" do
      let(:application_form) { create(:application_form) }

      let(:work_history) do
        build(
          :work_history,
          :completed,
          application_form:,
          contact_email: "INVALID",
        )
      end

      it { is_expected.to be false }

      context "with a reduced evidence application form" do
        let(:application_form) do
          create(:application_form, reduced_evidence_accepted: true)
        end

        it { is_expected.to be true }
      end
    end
  end
end
