import dfeAutocomplete from "dfe-autocomplete";
import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";
import checkboxSearchFilter from "./checkbox_search_filter";

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
    document.getElementById(
      "teacher-interface-work-history-form-country-location-field"
    ) ??
    document.getElementById(
      "teacher-interface-work-history-form-country-location-field-error"
    ) ??
    document.getElementById(
      "teacher-interface-work-history-school-form-country-location-field"
    ) ??
    document.getElementById(
      "teacher-interface-work-history-school-form-country-location-field-error"
    ) ??
    document.getElementById(
      "teacher-interface-qualification-form-institution-country-location-field"
    ) ??
    document.getElementById(
      "teacher-interface-qualification-form-institution-country-location-field-error"
    ) ??
    document.getElementById("assessor-interface-filter-form-location-field") ??
    document.getElementById(
      "assessor-interface-filter-form-location-field-error"
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
dfeAutocomplete({ rawAttribute: true });

checkboxSearchFilter("app-applications-filters-assessor", "Search assessors");
