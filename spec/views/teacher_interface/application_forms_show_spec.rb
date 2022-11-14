require "rails_helper"

RSpec.describe "teacher_interface/application_forms/show.html.erb",
               type: :view do
  before do
    assign(
      :view_object,
      TeacherInterface::ApplicationFormShowViewObject.new(
        current_teacher: application_form.teacher,
      ),
    )
  end

  subject { render }

  context "when awarded pending checks" do
    let(:application_form) do
      create(:application_form, :awarded_pending_checks)
    end

    it { is_expected.to match(/Application complete/) }
    it { is_expected.to match(/We’ve received your application for QTS/) }
  end

  context "when awarded" do
    let(:teacher) { create(:teacher, trn: "ABCDEF") }
    let(:application_form) { create(:application_form, :awarded, teacher:) }

    it { is_expected.to match(/Your QTS application was successful/) }
    it { is_expected.to match(/ABCDEF/) }
  end

  context "when declined" do
    let(:application_form) { create(:application_form, :declined) }
    let(:assessment) { create(:assessment, application_form:) }

    context "and an initial assessment" do
      before do
        create(
          :assessment_section,
          :failed,
          key: :personal_information,
          assessment:,
        )
      end

      it { is_expected.to match(/Your QTS application has been declined/) }
      it { is_expected.to match(/Notes/) }
      it { is_expected.to match(/you can make a new application in future/) }
    end

    context "and a further information request" do
      let(:further_information_request) do
        create(:further_information_request, assessment:)
      end

      before do
        create(
          :further_information_request_item,
          further_information_request:,
          assessor_notes: "A note",
        )
      end

      it { is_expected.to match(/Your QTS application has been declined/) }
      it { is_expected.to match(/you can make a new application in future/) }

      it "does not show the assessor notes to the applicant" do
        expect(subject).not_to match(/A note/)
      end
    end

    context "and with sanctions" do
      before do
        create(
          :assessment_section,
          :failed,
          key: :personal_information,
          selected_failure_reasons: {
            authorisation_to_teach: "Sanctions.",
          },
          assessment:,
        )
      end

      it do
        is_expected.to_not match(/you can make a new application in future/)
      end
    end
  end
end
