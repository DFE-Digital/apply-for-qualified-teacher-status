# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::PrioritisationReferenceRequestConfirmApplicantResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(
      prioritisation_reference_request:,
      confirm_applicant_response:,
      confirm_applicant_comment:,
    )
  end

  let(:prioritisation_reference_request) do
    create(:prioritisation_reference_request)
  end

  describe "validations" do
    let(:confirm_applicant_response) { "" }
    let(:confirm_applicant_comment) { "" }

    it do
      expect(subject).to validate_presence_of(:prioritisation_reference_request)
    end

    it do
      expect(subject).to allow_values(true, false).for(
        :confirm_applicant_response,
      )
    end

    it { is_expected.not_to validate_presence_of(:confirm_applicant_comment) }

    context "with a negative response" do
      let(:confirm_applicant_response) { "false" }

      it { is_expected.to validate_presence_of(:confirm_applicant_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:confirm_applicant_response) { "true" }
      let(:confirm_applicant_comment) { "" }

      it "sets confirm_applicant_response" do
        expect { save }.to change(
          prioritisation_reference_request,
          :confirm_applicant_response,
        ).to(true)
      end

      it "ignores confirm_applicant_comment" do
        expect { save }.not_to change(
          prioritisation_reference_request,
          :confirm_applicant_comment,
        )
      end
    end

    context "with a negative response" do
      let(:confirm_applicant_response) { "false" }
      let(:confirm_applicant_comment) { "Comment" }

      it "sets confirm_applicant_response" do
        expect { save }.to change(
          prioritisation_reference_request,
          :confirm_applicant_response,
        ).to(false)
      end

      it "sets confirm_applicant_comment" do
        expect { save }.to change(
          prioritisation_reference_request,
          :confirm_applicant_comment,
        ).to("Comment")
      end
    end
  end
end
