module PageObjects
  class GovukCheckboxItem < SitePrism::Section
    element :label, "label"
    element :checkbox, "input", visible: false
  end
end
