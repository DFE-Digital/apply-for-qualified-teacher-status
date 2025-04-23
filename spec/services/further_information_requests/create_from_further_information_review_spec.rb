# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequests::CreateFromFurtherInformationReview do
  subject(:call) { described_class.call(further_information_request:, user:) }

  let(:new_further_information_request) do
    assessment.reload.latest_further_information_request
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:further_information_request) do
    create :received_further_information_request,
           :with_items,
           assessment:,
           reviewed_at: Time.current,
           review_passed: false
  end
  let(:user) { create(:staff) }

  let(:items) { further_information_request.items.order(:created_at) }

  let(:first_item) { items.first }
  let(:third_item) { items.third }

  before do
    first_item.review_decision_further_information!
    first_item.update!(review_decision_note: "Provide more information.")

    third_item.review_decision_further_information!
    third_item.update!(review_decision_note: "Provide more information.")
  end

  it "generates a new further information request" do
    expect { call }.to change(
      assessment.further_information_requests,
      :count,
    ).from(1).to(2)
  end

  it "marks the new further information request to requested" do
    call

    expect(new_further_information_request.requested?).to be true
  end

  it "creates items for reviewed items that require further information" do
    call

    expect(new_further_information_request.items.count).to eq 2
    expect(
      new_further_information_request.items.find_by(
        information_type: first_item.information_type,
      ),
    ).to have_attributes(
      information_type: first_item.information_type,
      failure_reason_key: first_item.failure_reason_key,
      failure_reason_assessor_feedback: "Provide more information.",
      work_history: first_item.work_history,
    )
    expect(
      new_further_information_request.items.find_by(
        information_type: third_item.information_type,
      ),
    ).to have_attributes(
      information_type: third_item.information_type,
      failure_reason_key: third_item.failure_reason_key,
      failure_reason_assessor_feedback: "Provide more information.",
      work_history: third_item.work_history,
    )
  end

  it "changes the application form statuses" do
    expect { call }.to change(application_form, :statuses).to(
      %w[waiting_on_further_information],
    )
  end

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :further_information_requested,
      )
    end
  end

  it "sets the assessment recommendation" do
    expect { call }.to change(assessment, :request_further_information?).from(
      false,
    ).to(true)
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end

  context "with an existing request not yet received" do
    before { create(:further_information_request, assessment:) }

    it "raises an error" do
      expect { call }.to raise_error(
        FurtherInformationRequests::CreateFromFurtherInformationReview::AlreadyExists,
      )
    end
  end
end
