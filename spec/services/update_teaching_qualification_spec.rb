# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateTeachingQualification do
  subject(:call) do
    described_class.call(
      qualification:,
      user:,
      certificate_date:,
      complete_date:,
      institution_name:,
      start_date:,
      title:,
      teaching_qualification_part_of_degree:,
    )
  end

  let(:application_form) do
    create :application_form,
           :submitted,
           :with_work_history,
           :with_assessment,
           teaching_qualification_part_of_degree: false
  end

  let(:qualification) { create :qualification, :completed, application_form: }
  let(:user) { create(:staff) }
  let(:certificate_date) { Date.parse("1999-1-1") }
  let(:complete_date) { Date.parse("1998-1-1") }
  let(:start_date) { Date.parse("1995-1-1") }

  let(:title) { "New title" }
  let(:institution_name) { "New institution name" }

  let(:teaching_qualification_part_of_degree) { true }

  it "changes the teaching qualification title" do
    expect { call }.to change(qualification, :title).to(title)
  end

  it "changes the teaching qualification institution name" do
    expect { call }.to change(qualification, :institution_name).to(
      institution_name,
    )
  end

  it "changes the teaching qualification start date" do
    expect { call }.to change(qualification, :start_date).to(start_date)
  end

  it "changes the teaching qualification complete date" do
    expect { call }.to change(qualification, :complete_date).to(complete_date)
  end

  it "changes the teaching qualification certificate date" do
    expect { call }.to change(qualification, :certificate_date).to(
      certificate_date,
    )
  end

  it "changes the applications teaching qualification part of degree value" do
    expect { call }.to change(
      qualification.application_form,
      :teaching_qualification_part_of_degree,
    )
  end

  it "records timeline event for title change" do
    existing_title = qualification.title

    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "title",
      ),
    ).to have_attributes(
      creator: user,
      old_value: existing_title,
      new_value: title,
      application_form:,
      qualification:,
    )
  end

  it "records timeline event for institution name change" do
    existing_institution_name = qualification.institution_name

    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "institution_name",
      ),
    ).to have_attributes(
      creator: user,
      old_value: existing_institution_name,
      new_value: institution_name,
      application_form:,
      qualification:,
    )
  end

  it "records timeline event for start date change" do
    existing_start_date = qualification.start_date

    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "start_date",
      ),
    ).to have_attributes(
      creator: user,
      old_value: existing_start_date.to_fs(:month_and_year),
      new_value: start_date.to_fs(:month_and_year),
      application_form:,
      qualification:,
    )
  end

  it "records timeline event for complete date change" do
    existing_complete_date = qualification.complete_date

    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "complete_date",
      ),
    ).to have_attributes(
      creator: user,
      old_value: existing_complete_date.to_fs(:month_and_year),
      new_value: complete_date.to_fs(:month_and_year),
      application_form:,
      qualification:,
    )
  end

  it "records timeline event for certificate date change" do
    existing_certificate_date = qualification.certificate_date

    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "certificate_date",
      ),
    ).to have_attributes(
      creator: user,
      old_value: existing_certificate_date.to_fs(:month_and_year),
      new_value: certificate_date.to_fs(:month_and_year),
      application_form:,
      qualification:,
    )
  end

  it "records timeline event for part of degree change" do
    call

    expect(
      application_form.timeline_events.find_by(
        event_type: :information_changed,
        column_name: "teaching_qualification_part_of_degree",
      ),
    ).to have_attributes(
      creator: user,
      old_value: "No",
      new_value: "Yes",
      application_form:,
      qualification:,
    )
  end

  context "when the application is in review stage" do
    let(:application_form) do
      create :application_form,
             :submitted,
             :with_work_history,
             :with_assessment,
             :review_stage,
             teaching_qualification_part_of_degree: false
    end

    before { allow(UpdateAssessmentInductionRequired).to receive(:call) }

    it "calls the UpdateAssessmentInductionRequired" do
      call

      expect(UpdateAssessmentInductionRequired).to have_received(:call).with(
        assessment: application_form.assessment,
      )
    end
  end

  context "when the qualification is not the teaching qualification" do
    before do
      create :qualification,
             :completed,
             application_form:,
             created_at: qualification.created_at - 1.day
    end

    it "raises NotTeachingQualification" do
      expect { call }.to raise_error(
        UpdateTeachingQualification::NotTeachingQualification,
        "Qualification is not the teaching qualification and cannot be updated",
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::NotTeachingQualification
          # Do Nothing
        end
      }.not_to change(qualification.reload, :title)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::NotTeachingQualification
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the application form is in verification stage" do
    let(:application_form) do
      create :application_form,
             :submitted,
             :with_work_history,
             :with_assessment,
             :verification_stage,
             teaching_qualification_part_of_degree: false
    end

    it "raises InvalidState" do
      expect { call }.to raise_error(
        UpdateTeachingQualification::InvalidState,
        "Teaching qualification can only be update while the application is in assessment or review stage",
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to change(qualification.reload, :title)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the application form has already completed" do
    let(:application_form) { create :application_form, :awarded }

    it "raises InvalidState" do
      expect { call }.to raise_error(
        UpdateTeachingQualification::InvalidState,
        "Teaching qualification can only be update while the application is in assessment or review stage",
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to change(qualification.reload, :title)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the new qualification results in application form having less than 9 months work history" do
    before do
      application_form.work_histories.update_all(
        start_date: certificate_date - 5.years,
        end_date: complete_date + 5.months,
      )
    end

    it "raises InvalidWorkHistoryDuration" do
      expect { call }.to raise_error(
        UpdateTeachingQualification::InvalidWorkHistoryDuration,
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidWorkHistoryDuration
          # Do Nothing
        end
      }.not_to change(qualification.reload, :title)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue UpdateTeachingQualification::InvalidWorkHistoryDuration
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end
end
