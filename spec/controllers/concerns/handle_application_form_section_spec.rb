# frozen_string_literal: true

require "rails_helper"

RSpec.describe HandleApplicationFormSection, type: :controller do
  subject(:controller) { controller_class.new }

  let(:controller_class) do
    Class.new(TeacherInterface::BaseController) do
      include HandleApplicationFormSection
    end
  end
  let(:session) { {} }
  let(:current_teacher) { create(:teacher) }
  let(:request) do
    ActionController::TestRequest.new({}, {}, TeacherInterface::BaseController)
  end

  before do
    allow(controller).to receive_messages(
      params:,
      session:,
      current_teacher:,
      request:,
    )
  end

  describe "#handle_application_form_section" do
    subject(:handle_application_form_section) do
      controller.handle_application_form_section(
        form:,
        if_success_then_redirect:,
        if_failure_then_render:,
      )
    end

    let(:form) { instance_double(TeacherInterface::BaseForm, errors: []) }
    let(:if_success_then_redirect) { :redirect }
    let(:if_failure_then_render) { :render }

    context "when save and continue" do
      let(:params) { { next: "save_and_continue" } }

      context "when form is valid" do
        before { allow(form).to receive(:save).and_return(true) }

        it "redirects to success" do
          expect(controller).to receive(:redirect_to)
          handle_application_form_section
        end

        it "does not use the save-and-return destination when continuing" do
          expect(controller).to receive(:redirect_to).with(:redirect)

          controller.handle_application_form_section(
            form:,
            if_success_then_redirect: :redirect,
            if_save_and_come_back_later_then_redirect: "/custom-return",
          )
        end

        context "with a check entry in the history" do
          let(:session) do
            {
              history_stack: [
                {
                  path: "/teacher/application/personal_information/check",
                  check: true,
                },
                { path: "/teacher/application" },
              ],
            }
          end

          it "still returns to the check page" do
            expect(controller).to receive(:redirect_to).with(
              "/teacher/application/personal_information/check",
            )
            handle_application_form_section
          end
        end
      end

      context "when form is invalid" do
        let(:error) do
          ActiveModel::Error.new(
            TeacherInterface::NameAndDateOfBirthForm.new,
            :given_names,
          )
        end

        let(:form) do
          instance_double(
            TeacherInterface::NameAndDateOfBirthForm,
            errors: [error],
          )
        end

        before { allow(form).to receive(:save).and_return(false) }

        it "renders the failure and sends a custom form_validation_failure event to BigQuery" do
          expect(controller).to receive(:render)

          handle_application_form_section

          expect(
            :form_validation_failure,
          ).to have_been_enqueued_as_analytics_events
        end
      end
    end

    context "when save and come back later" do
      let(:params) { { button: "save_and_return" } }

      before { allow(form).to receive(:save).and_return(true) }

      it "redirects to application form" do
        expect(controller).to receive(:redirect_to).with(
          %i[teacher_interface application_form],
        )
        handle_application_form_section
      end

      it "saves without requiring complete answers" do
        allow(controller).to receive(:redirect_to)

        handle_application_form_section

        expect(form).to have_received(:save).with(validate: false)
      end

      it "uses an explicitly supplied save-and-return destination" do
        path = "/teacher/application/further_information_requests/1"
        expect(controller).to receive(:redirect_to).with(path)

        controller.handle_application_form_section(
          form:,
          if_save_and_come_back_later_then_redirect: path,
        )

        expect(form).to have_received(:save).with(validate: false)
      end

      context "with a check entry in the history" do
        let(:session) do
          {
            history_stack: [
              {
                path: "/teacher/application/personal_information/check",
                check: true,
              },
              { path: "/teacher/application" },
            ],
          }
        end

        it "returns to the application form rather than the check page" do
          expect(controller).to receive(:redirect_to).with(
            %i[teacher_interface application_form],
          )
          handle_application_form_section
        end
      end
    end
  end
end
