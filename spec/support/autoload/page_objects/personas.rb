module PageObjects
  class Personas < SitePrism::Page
    set_url "/personas"

    element :heading, "h1"

    section :staff, "#app-personas-staff" do
      element :heading, "h2"
      elements :buttons, ".govuk-button"
    end

    section :teachers, "#app-personas-teachers" do
      element :heading, "h2"
      elements :buttons, ".govuk-button"
    end

    section :references, "#app-personas-references" do
      element :heading, "h2"
      elements :buttons, ".govuk-button"
    end
  end
end
