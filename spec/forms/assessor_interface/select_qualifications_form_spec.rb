# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::SelectQualificationsForm, type: :model do
  let(:application_form) { create(:application_form, :submitted) }
  let(:qualification_1) do
    create(:qualification, :completed, application_form:)
  end
  let(:qualification_2) do
    create(:qualification, :completed, application_form:)
  end
  let(:session) { {} }
  let(:qualification_ids) { "" }

  subject(:form) do
    described_class.new(application_form:, session:, qualification_ids:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to_not allow_values(nil).for(:session) }
    it { is_expected.to validate_presence_of(:qualification_ids) }
    it do
      is_expected.to validate_inclusion_of(:qualification_ids).in_array(
        [qualification_1.id.to_s, qualification_2.id.to_s],
      )
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:qualification_ids) do
      [qualification_1.id.to_s, qualification_2.id.to_s]
    end

    it { is_expected.to be true }

    it "changes the session" do
      expect { save }.to change { session[:qualification_ids] }.to(
        [qualification_1.id.to_s, qualification_2.id.to_s],
      )
    end
  end
end
