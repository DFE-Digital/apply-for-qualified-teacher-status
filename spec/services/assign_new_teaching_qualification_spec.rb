# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignNewTeachingQualification do
  subject(:call) do
    described_class.call(
      current_teaching_qualification:,
      new_teaching_qualification:,
      user:,
    )
  end

  let(:application_form) do
    create :application_form,
           :submitted,
           :with_work_history,
           :with_assessment,
           teaching_qualification_part_of_degree: false
  end

  let!(:current_teaching_qualification) do
    create :qualification,
           :completed,
           application_form:,
           created_at: 2.days.ago,
           institution_country_code: application_form.country.code
  end

  let!(:new_teaching_qualification) do
    create :qualification,
           :completed,
           application_form:,
           created_at: 1.day.ago,
           institution_country_code: application_form.country.code
  end

  let(:user) { create(:staff) }

  it "changes the teaching qualification to the new qualification" do
    expect { call }.to change(
      application_form.reload,
      :teaching_qualification,
    ).to(new_teaching_qualification)
  end

  it "records timeline events" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      column_name: "teaching_qualification",
      old_value: current_teaching_qualification.title,
      new_value: new_teaching_qualification.title,
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

    before do
      allow(UpdateAssessmentInductionRequired).to receive(:call)
    end

    it 'calls the UpdateAssessmentInductionRequired' do
      call

      expect(UpdateAssessmentInductionRequired).to have_received(:call).with(
        assessment: application_form.assessment
      )
    end
  end

  context "when the new teaching qualification being assigned is the teaching qualification already" do
    let(:new_teaching_qualification) { current_teaching_qualification }

    it "raises AlreadyReassigned" do
      expect { call }.to raise_error(
        AssignNewTeachingQualification::AlreadyReassigned,
        "Teaching qualification has already changed, please review and try again"
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::AlreadyReassigned
          # Do Nothing
        end
      }.not_to change(application_form.reload, :teaching_qualification)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::AlreadyReassigned
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
        AssignNewTeachingQualification::InvalidState,
        "Teaching qualification can only be update while the application is in assessment or review stage"
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to change(application_form.reload, :teaching_qualification)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the application form has already completed" do
    let(:application_form) { create :application_form, :awarded }

    it "raises InvalidState" do
      expect { call }.to raise_error(
        AssignNewTeachingQualification::InvalidState,
        "Teaching qualification can only be update while the application is in assessment or review stage"
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to change(application_form.reload, :teaching_qualification)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidState
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the new qualification is from a different country to the application" do
    let(:new_teaching_qualification) do
      create :qualification,
             :completed,
             application_form:,
             created_at: 1.day.ago,
             institution_country_code: "IR"
    end

    it "raises InvalidInstitutionCountry" do
      expect { call }.to raise_error(
        AssignNewTeachingQualification::InvalidInstitutionCountry,
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidInstitutionCountry
          # Do Nothing
        end
      }.not_to change(application_form.reload, :teaching_qualification)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidInstitutionCountry
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end

  context "when the new qualification results in application form having less than 9 months work history" do
    before do
      application_form.work_histories.update_all(
        start_date: new_teaching_qualification.certificate_date - 5.years,
        end_date: new_teaching_qualification.complete_date + 5.months
      )
    end

    it "raises InvalidWorkHistoryDuration" do
      expect { call }.to raise_error(
        AssignNewTeachingQualification::InvalidWorkHistoryDuration,
      )
    end

    it "does not changes the teaching qualification" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidWorkHistoryDuration
          # Do Nothing
        end
      }.not_to change(application_form.reload, :teaching_qualification)
    end

    it "does not record a timeline events" do
      expect {
        begin
          call
        rescue AssignNewTeachingQualification::InvalidWorkHistoryDuration
          # Do Nothing
        end
      }.not_to have_recorded_timeline_event
    end
  end
end
