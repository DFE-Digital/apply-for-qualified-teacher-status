# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor Interface - Draft Applications", type: :request do
  let(:staff) { create(:staff) }
  let(:draft) do
    create(
      :application_form,
      teacher: create(:teacher, email: "draft-applicant@example.com"),
    )
  end

  before do
    FeatureFlags::FeatureFlag.activate(:sign_in_with_active_directory)
    sign_in(staff)
  end

  after { FeatureFlags::FeatureFlag.deactivate(:sign_in_with_active_directory) }

  describe "staff-only access" do
    [
      %i[get assessor_interface_draft_application_forms_path ok],
      %i[get assessor_interface_draft_application_form_path ok],
      %i[
        post
        filters_apply_assessor_interface_draft_application_forms_path
        found
      ],
      %i[
        get
        filters_clear_assessor_interface_draft_application_forms_path
        found
      ],
    ].each do |verb, route, expected_status|
      context "for #{route}" do
        let(:path) do
          if route == :assessor_interface_draft_application_form_path
            public_send(route, draft)
          else
            public_send(route)
          end
        end

        let(:request_params) do
          if verb == :post
            {
              assessor_interface_draft_application_forms_filter_form: {
                email: draft.teacher.email,
              },
            }
          else
            {}
          end
        end

        it "allows active staff without additional permissions" do
          public_send(verb, path, params: request_params)

          expect(response).to have_http_status(expected_status)
        end

        it "requires a signed-in staff member" do
          sign_out(staff)

          public_send(verb, path, params: request_params)

          expect(response).to redirect_to("/staff/auth/entra_id")
        end

        it "denies archived staff" do
          staff.update!(archived: true)

          public_send(verb, path, params: request_params)

          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
