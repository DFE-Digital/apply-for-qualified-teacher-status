# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::PrioritisationReferenceRequestContactResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(
      prioritisation_reference_request:,
      contact_response:,
      contact_comment:,
    )
  end

  let(:prioritisation_reference_request) do
    create(:prioritisation_reference_request)
  end

  describe "validations" do
    let(:contact_response) { "" }
    let(:contact_comment) { "" }

    it do
      expect(subject).to validate_presence_of(:prioritisation_reference_request)
    end

    it { is_expected.to allow_values(true, false).for(:contact_response) }
    it { is_expected.not_to validate_presence_of(:contact_comment) }

    context "with a negative response" do
      let(:contact_response) { "false" }

      it { is_expected.to validate_presence_of(:contact_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:contact_response) { "true" }
      let(:contact_comment) { "" }

      it "sets contact_response" do
        expect { save }.to change(
          prioritisation_reference_request,
          :contact_response,
        ).to(true)
      end

      it "ignores contact_comment" do
        expect { save }.not_to change(
          prioritisation_reference_request,
          :contact_comment,
        )
      end
    end

    context "with a negative response" do
      let(:contact_response) { "false" }
      let(:contact_comment) { "Comment" }

      it "sets contact_response" do
        expect { save }.to change(
          prioritisation_reference_request,
          :contact_response,
        ).to(false)
      end

      it "sets contact_comment" do
        expect { save }.to change(
          prioritisation_reference_request,
          :contact_comment,
        ).to("Comment")
      end
    end
  end
end
