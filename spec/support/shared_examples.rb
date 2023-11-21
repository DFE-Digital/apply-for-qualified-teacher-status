# frozen_string_literal: true

RSpec.shared_examples "redirect unless application form is draft" do
  context "with a submitted application form" do
    before { application_form.update!(submitted_at: Time.zone.now) }

    it "redirects to the application form" do
      perform
      expect(response).to redirect_to(teacher_interface_application_form_path)
    end
  end
end
