import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

initAll();

openregisterLocationPicker({
  selectElement: document.getElementById("location-form-country-code-field"),
  url: "/teacher/locations.json",
});
