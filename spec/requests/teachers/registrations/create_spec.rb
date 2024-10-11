# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /teacher", type: :request do
  subject(:register) { post teacher_registration_path, params: }

  let(:email) { "test@test.com" }
  let(:params) { { teacher: { email: } } }

  it "creates a new teacher record" do
    expect { register }.to change(Teacher, :count).by(1)

    teacher = Teacher.last

    expect(teacher).to have_attributes(email:)
  end

  it "sends the email a magic sign in link" do
    expect { register }.to have_enqueued_mail(DeviseMailer, :magic_link).with(
      Teacher.last,
    )
  end

  it "redirects to check your email page" do
    register

    expect(response).to redirect_to(teacher_check_email_path(email:))
  end

  context "when the email is invalid" do
    let(:email) { "INVALID" }

    it "does not create a new teacher record" do
      expect { register }.not_to change(Teacher, :count)
    end

    it "does not send the email a magic sign in link" do
      expect { register }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end
  end

  context "when there is an existing teacher record with the same email" do
    let!(:teacher) { create :teacher, email: }

    it "does not create a new teacher record" do
      expect { register }.not_to change(Teacher, :count)
    end

    it "sends the email a magic sign in link" do
      expect { register }.to have_enqueued_mail(DeviseMailer, :magic_link)
    end

    it "redirects to check your email page" do
      register

      expect(response).to redirect_to(teacher_check_email_path(email:))
    end
  end

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it "does not create a new teacher record" do
      expect { register }.not_to change(Teacher, :count)
    end

    it "does not send the email a magic sign in link" do
      expect { register }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end

    it "redirects to the GOV.UK One Login flow" do
      register

      expect(response).to redirect_to "/teacher/auth/gov_one"
    end
  end
end
