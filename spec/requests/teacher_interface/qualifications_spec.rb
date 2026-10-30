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

  describe "PATCH /teacher/application/qualifications/:id" do
    subject(:perform) do
      patch teacher_interface_application_form_qualification_path(
              qualification,
            ),
            params: {
              button:,
              teacher_interface_qualification_form: form_params,
            }
    end

    let!(:teaching_qualification) do
      create(:qualification, :completed, application_form:)
    end
    let(:qualification) { create(:qualification, application_form:) }
    let(:button) { "save_and_continue" }
    let(:check_path) do
      check_teacher_interface_application_form_qualifications_path
    end

    let(:form_params) do
      {
        :title => "Example additional diploma",
        :institution_name => "Example University",
        :institution_country_location => "country:FR",
        "start_date(1i)" => "2010",
        "start_date(2i)" => "1",
        "start_date(3i)" => "1",
        "complete_date(1i)" => "2013",
        "complete_date(2i)" => "6",
        "complete_date(3i)" => "1",
        "certificate_date(1i)" => "2013",
        "certificate_date(2i)" => "7",
        "certificate_date(3i)" => "1",
      }
    end

    before do
      qualification
      get check_path
      get edit_teacher_interface_application_form_qualification_path(
            qualification,
          )
    end

    it "continues a resumed qualification to its certificate rather than the check page" do
      perform

      expect(response).to redirect_to(
        teacher_interface_application_form_document_path(
          qualification.certificate_document,
        ),
      )
    end

    context "with a certificate but no transcript" do
      before do
        create(:upload, :clean, document: qualification.certificate_document)
      end

      it "continues to review the existing certificate" do
        perform

        expect(response).to redirect_to(
          teacher_interface_application_form_document_path(
            qualification.certificate_document,
          ),
        )
      end
    end

    context "with an already completed qualification" do
      let(:qualification) do
        create(:qualification, :completed, application_form:)
      end

      it "returns to the collection check page" do
        perform

        expect(response).to redirect_to(check_path)
      end

      context "when editing from the individual check page" do
        let(:check_path) do
          check_teacher_interface_application_form_qualification_path(
            qualification,
          )
        end

        it "returns to the individual check page" do
          perform

          expect(response).to redirect_to(check_path)
        end
      end
    end

    context "with both documents already uploaded" do
      before do
        create(:upload, :clean, document: qualification.certificate_document)
        create(:upload, :clean, document: qualification.transcript_document)
      end

      it "returns to the check page when saving the details completes the qualification" do
        expect(qualification).to be_incomplete

        perform

        expect(qualification.reload).to be_complete
        expect(response).to redirect_to(check_path)
      end
    end

    context "without a check page in the history" do
      let(:check_path) { teacher_interface_application_form_path }

      it "continues to the certificate document" do
        perform

        expect(response).to redirect_to(
          teacher_interface_application_form_document_path(
            qualification.certificate_document,
          ),
        )
      end
    end

    context "with invalid details" do
      let(:form_params) do
        {
          :title => "",
          :institution_name => "",
          :institution_country_location => "",
          "start_date(1i)" => "",
          "start_date(2i)" => "",
          "start_date(3i)" => "",
          "complete_date(1i)" => "",
          "complete_date(2i)" => "",
          "complete_date(3i)" => "",
          "certificate_date(1i)" => "",
          "certificate_date(2i)" => "",
          "certificate_date(3i)" => "",
        }
      end

      it "renders validation errors without progressing" do
        perform

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("govuk-error-summary")
        expect(qualification.reload.title).to eq("")
      end
    end

    context "when saving and coming back later" do
      let(:button) { "save_and_return" }
      let(:form_params) do
        {
          :title => "Example partial diploma",
          :institution_name => "",
          :institution_country_location => "",
          "start_date(1i)" => "",
          "start_date(2i)" => "",
          "start_date(3i)" => "",
          "complete_date(1i)" => "",
          "complete_date(2i)" => "",
          "complete_date(3i)" => "",
          "certificate_date(1i)" => "",
          "certificate_date(2i)" => "",
          "certificate_date(3i)" => "",
        }
      end

      it "saves partial answers and returns to the task list" do
        perform

        expect(response).to redirect_to(teacher_interface_application_form_path)
        expect(qualification.reload.title).to eq("Example partial diploma")
        expect(qualification).to be_incomplete
      end
    end

    context "with a completed teaching qualification" do
      let(:qualification) { teaching_qualification }
      let(:form_params) do
        {
          :title => "Example additional diploma",
          :institution_name => "Example University",
          :institution_country_location =>
            CountryCode.to_location(application_form.country.code),
          :teaching_confirmation => "true",
          "start_date(1i)" => "2010",
          "start_date(2i)" => "1",
          "start_date(3i)" => "1",
          "complete_date(1i)" => "2013",
          "complete_date(2i)" => "6",
          "complete_date(3i)" => "1",
          "certificate_date(1i)" => "2013",
          "certificate_date(2i)" => "7",
          "certificate_date(3i)" => "1",
        }
      end

      it "returns to the check page after confirming the amended details" do
        perform

        expect(response).to redirect_to(check_path)
      end
    end
  end

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
