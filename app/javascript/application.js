import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

initAll();

var loadCountryAutoComplete = () => {
  var locationPicker =
    document.getElementById(
      "eligibility-interface-country-form-location-field"
    ) ??
    document.getElementById(
      "eligibility-interface-country-form-location-field-error"
    ) ??
    document.getElementById(
      "teacher-interface-country-region-form-location-field"
    ) ??
    document.getElementById(
      "teacher-interface-country-region-form-location-field-error"
    ) ??
    document.getElementById("work-history-country-code-field") ??
    document.getElementById("work-history-country-code-field-error") ??
    document.getElementById("qualification-institution-country-code-field") ??
    document.getElementById(
      "qualification-institution-country-code-field-error"
    ) ??
    document.getElementById("location-field") ??
    document.getElementById("location-field-error");

  if (locationPicker) {
    openregisterLocationPicker({
      selectElement: locationPicker,
      url: "/autocomplete_locations.json",
      name: "location_autocomplete",
    });
  }
};

loadCountryAutoComplete();
