# frozen_string_literal: true

# == Schema Information
#
# Table name: work_histories
#
#  id                                :bigint           not null, primary key
#  address_line1                     :string
#  address_line2                     :string
#  canonical_contact_email           :text             default(""), not null
#  city                              :text             default(""), not null
#  contact_email                     :text             default(""), not null
#  contact_email_domain              :text             default(""), not null
#  contact_job                       :string           default(""), not null
#  contact_name                      :text             default(""), not null
#  country_code                      :text             default(""), not null
#  end_date                          :date
#  end_date_is_estimate              :boolean          default(FALSE), not null
#  hours_per_week                    :integer
#  is_other_england_educational_role :boolean          default(FALSE), not null
#  job                               :text             default(""), not null
#  postcode                          :string
#  school_name                       :text             default(""), not null
#  school_website                    :string
#  start_date                        :date
#  start_date_is_estimate            :boolean          default(FALSE), not null
#  still_employed                    :boolean
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  application_form_id               :bigint           not null
#  eligibility_domain_id             :bigint
#
# Indexes
#
#  index_work_histories_on_application_form_id      (application_form_id)
#  index_work_histories_on_canonical_contact_email  (canonical_contact_email)
#  index_work_histories_on_eligibility_domain_id    (eligibility_domain_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (eligibility_domain_id => eligibility_domains.id)
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

  describe "#current_or_most_recent_teaching_role?" do
    subject(:current_or_most_recent_teaching_role?) do
      work_history.current_or_most_recent_teaching_role?
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

    context "when there are saved other England work histories" do
      before do
        create(
          :work_history,
          :other_england_role,
          application_form: work_history.application_form,
        )
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#initial_other_england_educational_role_by_user?" do
    subject(:initial_other_england_educational_role_by_user?) do
      work_history.initial_other_england_educational_role_by_user?
    end

    let(:work_history) { build(:work_history, :other_england_role) }

    context "when there are no saved other England work histories" do
      it { is_expected.to be(true) }
    end

    context "when there are saved other England work histories and this is the first" do
      before { work_history.save! }

      it { is_expected.to be(true) }
    end

    context "when there are saved other England work histories and this is not the first" do
      before do
        create(
          :work_history,
          :other_england_role,
          application_form: work_history.application_form,
        )
      end

      it { is_expected.to be(false) }
    end

    context "when there are saved teaching work histories" do
      before do
        create(:work_history, application_form: work_history.application_form)
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#complete?" do
    subject(:complete?) { work_history.complete? }

    it { is_expected.to be false }

    context "with a partially complete work history" do
      before { work_history.update!(school_name: "School name") }

      it { is_expected.to be false }
    end

    context "with a complete work history" do
      let(:work_history) { create(:work_history, :completed) }

      it { is_expected.to be true }
    end

    context "with postcode is not present" do
      let(:work_history) { create(:work_history, :completed, postcode: nil) }

      it { is_expected.to be true }

      context "when the work history is other England role" do
        let(:work_history) do
          create(:work_history, :other_england_role, :completed, postcode: nil)
        end

        it { is_expected.to be false }
      end
    end

    context "with hours worked is not present" do
      let(:work_history) do
        create(:work_history, :completed, hours_per_week: nil)
      end

      it { is_expected.to be false }

      context "when the work history is other England role" do
        let(:work_history) do
          create(
            :work_history,
            :other_england_role,
            :completed,
            hours_per_week: nil,
          )
        end

        it { is_expected.to be true }
      end
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

        context "when the application form includes prioritisation features" do
          let(:application_form) do
            create(
              :application_form,
              reduced_evidence_accepted: true,
              includes_prioritisation_features: true,
            )
          end

          it { is_expected.to be true }

          context "with work history from England" do
            let(:work_history) do
              build(
                :work_history,
                :completed,
                application_form:,
                contact_name: "",
                contact_job: "",
                contact_email: "",
                country_code: "GB-ENG",
              )
            end

            it { is_expected.to be false }
          end
        end
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

    context "with not still employed and end date present" do
      let(:work_history) do
        create(:work_history, :completed, still_employed: false, end_date:)
      end
      let(:end_date) { 11.months.ago.beginning_of_month }

      it { is_expected.to be true }

      context "when the work history is other England role" do
        let(:work_history) do
          create(
            :work_history,
            :other_england_role,
            :completed,
            still_employed: false,
            end_date:,
          )
        end

        it { is_expected.to be true }
      end

      context "with the end date being over 12 months ago" do
        let(:end_date) { 13.months.ago.beginning_of_month }

        it { is_expected.to be true }

        context "when the work history is other England role" do
          let(:work_history) do
            create(
              :work_history,
              :other_england_role,
              :completed,
              still_employed: false,
              end_date:,
            )
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe "#invalid_email_domain_for_contact?" do
    subject(:invalid_email_domain_for_contact?) do
      work_history.invalid_email_domain_for_contact?
    end

    it { is_expected.to be false }

    context "with contact email having a public email domain" do
      before { work_history.update!(contact_email_domain: "gmail.com") }

      it { is_expected.to be true }
    end

    context "with contact email having a private email domain" do
      before { work_history.update!(contact_email: "private.com") }

      it { is_expected.to be false }
    end
  end

  describe "#activate_eligibility_domain_concern?" do
    subject(:activate_eligibility_domain_concern?) do
      work_history.activate_eligibility_domain_concern?
    end

    context "when work history has no linked eligibility domain" do
      it { is_expected.to be false }
    end

    context "when work history has a linked eligibility domain" do
      let(:eligibility_domain) { create :eligibility_domain }

      before { work_history.update!(eligibility_domain:) }

      it { is_expected.to be true }

      context "with the linked eligibility domain archived" do
        let(:eligibility_domain) do
          create :eligibility_domain, archived_at: Time.current
        end

        it { is_expected.to be false }
      end
    end
  end
end
