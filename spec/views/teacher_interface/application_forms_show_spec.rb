require "rails_helper"

RSpec.describe "teacher_interface/application_forms/show.html.erb",
               type: :view do
  before do
    assign(
      :view_object,
      TeacherInterface::ApplicationFormViewObject.new(application_form:),
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
    it { is_expected.to match(/Access your teaching qualifications/) }
  end

  context "when declined" do
    let(:application_form) { create(:application_form, :declined) }
    let!(:assessment) { create(:assessment, application_form:) }

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
      it { is_expected.to match(/Why your application was declined/) }
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
          failure_reason_assessor_feedback: "A note",
        )
      end

      it { is_expected.to match(/Your QTS application has been declined/) }
      it { is_expected.to match(/you can make a new application in future/) }

      it "does not show the assessor notes to the applicant" do
        expect(subject).not_to match(/A note/)
      end
    end

    context "and an expired professional standing request" do
      before { create(:professional_standing_request, :expired, assessment:) }

      it do
        is_expected.to match(/Your QTS application has been declined/)
        is_expected.to match(
          /we did not receive your letter that proves you’re recognised as a teacher/,
        )
        is_expected.to match(/from teaching authority within 180 days/)
      end
    end

    context "and with sanctions" do
      before do
        create(:assessment_section, :declines_with_sanctions, assessment:)
      end

      it do
        is_expected.to_not match(/you can make a new application in future/)
      end
    end
  end
end
