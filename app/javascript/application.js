import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

initAll();

const loadCountryAutoComplete = () => {
  let locationPicker = document.getElementById(
    "eligibility-interface-country-form-location-field"
  );
  locationPicker ??= document.getElementById(
    "eligibility-interface-country-form-location-field-error"
  );

  if (locationPicker) {
    openregisterLocationPicker({
      selectElement: locationPicker,
      url: "/eligibility/locations.json",
    });
  }
};

loadCountryAutoComplete();
