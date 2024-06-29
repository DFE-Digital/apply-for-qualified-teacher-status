# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestContactResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(
      reference_request:,
      contact_response:,
      contact_name:,
      contact_job:,
      contact_comment:,
    )
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:contact_response) { "" }
    let(:contact_name) { "" }
    let(:contact_job) { "" }
    let(:contact_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:contact_response) }
    it { is_expected.not_to validate_presence_of(:contact_name) }
    it { is_expected.not_to validate_presence_of(:contact_job) }
    it { is_expected.not_to validate_presence_of(:contact_comment) }

    context "with a negative response" do
      let(:contact_response) { "false" }

      it { is_expected.to validate_presence_of(:contact_name) }
      it { is_expected.to validate_presence_of(:contact_job) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:contact_response) { "true" }
      let(:contact_name) { "" }
      let(:contact_job) { "" }
      let(:contact_comment) { "" }

      it "sets contact_response" do
        expect { save }.to change(reference_request, :contact_response).to(true)
      end

      it "ignores contact_name" do
        expect { save }.not_to change(reference_request, :contact_name)
      end

      it "ignores contact_job" do
        expect { save }.not_to change(reference_request, :contact_job)
      end

      it "ignores contact_comment" do
        expect { save }.not_to change(reference_request, :contact_comment)
      end
    end

    context "with a negative response" do
      let(:contact_response) { "false" }
      let(:contact_name) { "Name" }
      let(:contact_job) { "Job" }
      let(:contact_comment) { "Comment" }

      it "sets contact_response" do
        expect { save }.to change(reference_request, :contact_response).to(
          false,
        )
      end

      it "sets contact_name" do
        expect { save }.to change(reference_request, :contact_name).to("Name")
      end

      it "sets contact_job" do
        expect { save }.to change(reference_request, :contact_job).to("Job")
      end

      it "sets contact_comment" do
        expect { save }.to change(reference_request, :contact_comment).to(
          "Comment",
        )
      end
    end
  end
end
