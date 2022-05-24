import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

initAll();

const loadCountryAutoComplete = () => {
  let locationPicker = document.getElementById(
    "location-form-country-code-field"
  );
  locationPicker ??= document.getElementById(
    "location-form-country-code-field-error"
  );

  if (locationPicker) {
    openregisterLocationPicker({
      selectElement: locationPicker,
      url: "/teacher/locations.json",
    });
  }
};

loadCountryAutoComplete();
