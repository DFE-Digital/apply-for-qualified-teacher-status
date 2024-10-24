# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/teacher/auth/gov_one/callback", type: :request do
  subject(:gov_one_callback) { get "/teacher/auth/gov_one/callback" }

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      "uid" => gov_one_id,
      "info" => {
        "email" => email,
      },
      "credentials" => {
        "id_token" => "99999",
      },
    )
  end

  let(:gov_one_id) { "123456789" }
  let(:email) { "test@example.com" }

  before { OmniAuth.config.mock_auth[:default] = omniauth_hash }

  context "when the user is new and has a completed eligibility_check_id in session" do
    before { set_session({ eligibility_check_id: eligibility_check.id }) }

    context "with the teacher being eligible" do
      let(:eligibility_check) do
        create :eligibility_check, :complete, :eligible
      end

      it "generates a new teacher record" do
        expect { gov_one_callback }.to change(Teacher, :count).by(1)
      end

      it "redirects the teacher to the teacher interface" do
        gov_one_callback

        expect(response).to redirect_to(teacher_interface_root_path)
      end

      it "sets the id_token session" do
        gov_one_callback

        expect(request.session[:id_token]).to eq("99999")
      end
    end

    context "with the teacher being ineligible" do
      let(:eligibility_check) do
        create :eligibility_check, :complete, :ineligible
      end

      it "does not generate a new teacher record with an application" do
        expect { gov_one_callback }.not_to change(Teacher, :count)
      end

      it "redirects the teacher to eligibility countries selection" do
        gov_one_callback

        expect(response).to redirect_to(eligibility_interface_countries_path)
      end

      it "does not set the id_token session" do
        gov_one_callback

        expect(request.session[:id_token]).to be_nil
      end
    end
  end

  context "when the user is new and has an incompleted eligibility_check_id in session" do
    let(:eligibility_check) { create :eligibility_check }

    before { set_session({ eligibility_check_id: eligibility_check.id }) }

    it "does not generate a new teacher record with an application" do
      expect { gov_one_callback }.not_to change(Teacher, :count)
    end

    it "redirects the teacher to eligibility countries selection" do
      gov_one_callback

      expect(response).to redirect_to(eligibility_interface_countries_path)
    end

    it "does not set the id_token session" do
      gov_one_callback

      expect(request.session[:id_token]).to be_nil
    end
  end

  context "when the user has an existing teacher record" do
    before { create :teacher, email:, gov_one_id: }

    it "does not generate a new teacher record with an application" do
      expect { gov_one_callback }.not_to change(Teacher, :count)
    end

    it "redirects the teacher to the teacher interface" do
      gov_one_callback

      expect(response).to redirect_to(teacher_interface_root_path)
    end

    it "sets the id_token session" do
      gov_one_callback

      expect(request.session[:id_token]).to eq("99999")
    end
  end

  context "when no auth info is provided" do
    let(:omniauth_hash) { OmniAuth::AuthHash.new({}) }

    it "does not generate a new teacher record with an application" do
      expect { gov_one_callback }.not_to change(Teacher, :count)
    end

    it "does not set the id_token session" do
      gov_one_callback

      expect(request.session[:id_token]).to be_nil
    end

    it "redirects the user back to the sign in page" do
      gov_one_callback

      expect(response).to redirect_to(root_path)
      expect(request.flash[:alert]).to eq(
        "There was a problem signing in. Please try again.",
      )
    end
  end
end
