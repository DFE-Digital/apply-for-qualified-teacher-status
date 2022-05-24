import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

initAll();

const loadCountryAutoComplete = () => {
  let countryPicker = document.getElementById(
    "country-form-country-code-field"
  );
  countryPicker ??= document.getElementById(
    "country-form-country-code-field-error"
  );

  if (countryPicker) {
    openregisterLocationPicker({
      selectElement: countryPicker,
      url: "/teacher/locations.json",
    });
  }
};

loadCountryAutoComplete();
