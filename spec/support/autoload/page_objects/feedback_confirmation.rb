# frozen_string_literal: true

module PageObjects
  class FeedbackConfirmation < SitePrism::Page
    set_url "/feedback/confirmation"

    element :heading, "h1"

    element :return_to_application_link, "a", text: "Return to your application"
    element :close_page_message, "p", text: "You can now close this page"
  end
end
