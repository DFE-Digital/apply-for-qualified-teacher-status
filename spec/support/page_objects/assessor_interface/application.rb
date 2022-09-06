module PageObjects
  module AssessorInterface
    class Application < SitePrism::Page
      set_url "/assessor/applications/{application_id}"

      element :summary_list, "dl"
    end
  end
end
