# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher interface - Qualifications", type: :request do
  let(:teacher) { create(:teacher) }
  let!(:application_form) do
    create(
      :application_form,
      teacher:,
      teaching_qualification_part_of_degree: true,
    )
  end

  before { sign_in teacher, scope: :teacher }

  describe "GET /teacher/application/qualifications" do
    subject(:perform) do
      get teacher_interface_application_form_qualifications_path
    end

    it "redirects to new teaching qualification when there are no qualifications" do
      perform

      expect(response).to redirect_to(
        new_teacher_interface_application_form_qualification_path,
      )
    end

    context "with an incomplete teaching qualification" do
      let!(:qualification) { create(:qualification, application_form:) }

      it "redirects to edit the incomplete teaching qualification" do
        perform

        expect(response).to redirect_to(
          edit_teacher_interface_application_form_qualification_path(
            qualification,
          ),
        )
      end

      context "with an additional qualification" do
        before { create(:qualification, application_form:) }

        it "redirects to edit the incomplete teaching qualification" do
          perform

          expect(response).to redirect_to(
            edit_teacher_interface_application_form_qualification_path(
              qualification,
            ),
          )
        end
      end
    end

    context "with a completed teaching qualification" do
      before { create(:qualification, :completed, application_form:) }

      context "with a partially entered additional qualification" do
        before { create(:qualification, application_form:) }

        it "redirects to the qualifications check collection page" do
          perform

          expect(response).to redirect_to(
            check_teacher_interface_application_form_qualifications_path,
          )
        end
      end

      context "with a completed second and incomplete third qualification" do
        before do
          create(:qualification, :completed, application_form:)
          create(:qualification, application_form:)
        end

        it "redirects to the qualifications check collection page" do
          perform

          expect(response).to redirect_to(
            check_teacher_interface_application_form_qualifications_path,
          )
        end
      end

      context "when the qualifications task is complete" do
        before { ApplicationFormSectionStatusUpdater.call(application_form:) }

        it "redirects to the qualifications check collection page" do
          perform

          expect(response).to redirect_to(
            check_teacher_interface_application_form_qualifications_path,
          )
        end
      end
    end
  end
end
