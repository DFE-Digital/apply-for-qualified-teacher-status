module PageObjects
  class GovukRadioItem < SitePrism::Section
    element :input, ".govuk-radios__input", visible: false
    element :label, ".govuk-radios__label"
  end
end
