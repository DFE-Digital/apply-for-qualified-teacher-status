# frozen_string_literal: true

require "rails_helper"

RSpec.describe HandleApplicationFormSection, type: :controller do
  let(:controller_class) do
    Class.new(TeacherInterface::BaseController) do
      include HandleApplicationFormSection
    end
  end

  subject(:controller) { controller_class.new }
  before { allow(controller).to receive(:params).and_return(params) }

  describe "#handle_application_form_section" do
    let(:form) { double }
    let(:if_success_then_redirect) { :redirect }
    let(:if_failure_then_render) { :render }

    subject(:handle_application_form_section) do
      controller.handle_application_form_section(
        form:,
        if_success_then_redirect:,
        if_failure_then_render:,
      )
    end

    context "when save and continue" do
      let(:params) { { next: "save_and_continue" } }

      context "when form is valid" do
        before { allow(form).to receive(:save).and_return(true) }

        it "redirects to success" do
          expect(controller).to receive(:redirect_to)
          handle_application_form_section
        end
      end

      context "when form is invalid" do
        before { allow(form).to receive(:save).and_return(false) }

        it "renders the failure" do
          expect(controller).to receive(:render)
          handle_application_form_section
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
    end
  end
end
