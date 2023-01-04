# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageProviderForm, type: :model do
  let(:application_form) { create(:application_form) }
  let!(:providers) { create_list(:english_language_provider, 3) }

  subject(:form) { described_class.new(application_form:, provider_id:) }

  describe "validations" do
    let(:provider_id) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:provider_id) }
    it do
      is_expected.to validate_inclusion_of(:provider_id).in_array(
        providers.map(&:id).map(&:to_s),
      )
    end
  end

  describe "#save" do
    let(:provider_id) { providers.first.id.to_s }

    subject(:save) { form.save(validate: true) }

    it "saves the application form" do
      expect { save }.to change(
        application_form,
        :english_language_provider,
      ).to(providers.first)
    end
  end
end
