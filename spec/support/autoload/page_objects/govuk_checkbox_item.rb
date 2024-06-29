# frozen_string_literal: true

module PageObjects
  class GovukCheckboxItem < SitePrism::Section
    element :label, "label"
    element :checkbox, "input", visible: false

    def_delegator :checkbox, :click
  end
end
