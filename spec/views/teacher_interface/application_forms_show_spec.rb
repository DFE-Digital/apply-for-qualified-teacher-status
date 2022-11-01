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
      it { is_expected.to match(/A note/) }
    end
  end
end
