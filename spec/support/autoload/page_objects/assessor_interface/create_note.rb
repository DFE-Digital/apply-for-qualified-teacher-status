module PageObjects
  module AssessorInterface
    class CreateNote < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/notes/new"

      element :heading, "h1"

      section :form, "form" do
        element :text_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
