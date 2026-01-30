# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /teacher/sign_in", type: :request do
  subject(:sign_in) { post teacher_session_path, params: }

  let!(:teacher) { create :teacher, email: }

  let(:email) { "test@test.com" }
  let(:params) do
    {
      teacher_interface_new_session_form: {
        sign_in_or_sign_up: "sign_in",
        email:,
      },
    }
  end

  it "sends the email a magic sign in link" do
    expect { sign_in }.to have_enqueued_mail(DeviseMailer, :magic_link).with(
      teacher,
      any_args,
      {},
    )
  end

  it "redirects to check your email page" do
    sign_in

    expect(response).to redirect_to(teacher_check_email_path(email:))
  end

  context "when the email does not exist" do
    before { teacher.destroy }

    it "does not send the email a magic sign in link" do
      expect { sign_in }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end
  end

  context "when the sign_in_or_sign_up is not specified" do
    let(:params) { { teacher_interface_new_session_form: { email: } } }

    it "does not send the email a magic sign in link" do
      expect { sign_in }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end

    it "responds with an error message" do
      sign_in

      expect(response.body).to include(
        "Select if you have used the service before",
      )
    end
  end

  context "when the email has not been specified" do
    let(:params) do
      {
        teacher_interface_new_session_form: {
          sign_in_or_sign_up: "sign_in",
          email: "",
        },
      }
    end

    it "does not send the email a magic sign in link" do
      expect { sign_in }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end

    it "responds with an error message" do
      sign_in

      expect(response.body).to include("Enter your email address")
    end
  end

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it "does not send the email a magic sign in link" do
      expect { sign_in }.not_to have_enqueued_mail(DeviseMailer, :magic_link)
    end

    it "redirects to the GOV.UK One Login flow" do
      sign_in

      expect(response).to redirect_to "/teacher/auth/gov_one"
    end

    context "when the sign_in_or_sign_up is not specified" do
      let(:params) { { teacher_interface_new_session_form: { email: } } }

      it "does not redirect to the GOV.UK One Login flow" do
        sign_in

        expect(response).not_to redirect_to "/teacher/auth/gov_one"
      end

      it "responds with an error message" do
        sign_in

        expect(response.body).to include(
          "Select if you have used the service before",
        )
      end
    end
  end
end
