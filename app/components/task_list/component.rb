# frozen_string_literal: true

module TaskList
  class Component < ViewComponent::Base
    ##
    # Renders a task list from the following data structure:
    #
    # sections: [
    #   {
    #     title: "Title",
    #     items: [
    #       {
    #         name: "Do this thing",
    #         link: "/do-this-thing",
    #         status: "not_started"
    #       }
    #     ]
    #   }
    # ]

    def initialize(sections)
      super
      @sections = sections
    end

    def sections
      @sections
        .filter { |section| section[:items].present? }
        .each_with_index
        .map do |section, index|
          section.merge(
            number: index + 1,
            key: section[:title]&.parameterize,
            items:
              section[:items].map do |item|
                item.merge(key: item[:name].parameterize)
              end,
          )
        end
    end
  end
end
