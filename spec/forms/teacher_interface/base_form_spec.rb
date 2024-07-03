# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::BaseForm, type: :model do
  subject(:form) { form_class.new(application_form:, given_names:) }

  let(:form_class) do
    Class.new(TeacherInterface::BaseForm) do
      attr_accessor :application_form
      validates :application_form, presence: true

      attribute :given_names, :string
      validates :given_names, presence: true

      def update_model
        application_form.update!(given_names:)
      end
    end
  end

  let(:application_form) { create(:application_form, given_names: "Old name") }

  describe "#save" do
    subject(:save) { form.save(validate:) }

    shared_examples "success" do
      it { is_expected.to be true }

      it "updates the model" do
        expect(application_form.given_names).to eq("Old name")
        save # rubocop:disable Rails/SaveBang
        expect(application_form.given_names).to eq(given_names)
      end

      it "updates the application form status" do
        expect(ApplicationFormSectionStatusUpdater).to receive(:call).with(
          application_form:,
        )
        save # rubocop:disable Rails/SaveBang
      end
    end

    shared_examples "failure" do
      it { is_expected.to be false }

      it "doesn't update the model" do
        expect(application_form.given_names).to eq("Old name")
        save # rubocop:disable Rails/SaveBang
        expect(application_form.given_names).to eq("Old name")
      end
    end

    context "when form is invalid" do
      let(:given_names) { "" }

      context "saving with validation" do
        let(:validate) { true }

        include_examples "failure"
      end

      context "saving without validation" do
        let(:validate) { false }

        include_examples "success"
      end
    end

    context "when form is valid" do
      let(:given_names) { "New name" }

      context "saving with validation" do
        let(:validate) { true }

        include_examples "success"
      end

      context "saving without validation" do
        let(:validate) { false }

        include_examples "success"
      end
    end
  end
end
