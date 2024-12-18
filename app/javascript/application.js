import dfeAutocomplete from "dfe-autocomplete";
import { initAll } from "govuk-frontend";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";
import checkboxSearchFilter from "./checkbox_search_filter";
import suitabilityRecordForm from "./suitability_record_form";

initAll();

var loadCountryAutoComplete = () => {
  var locationPicker =
    document.getElementById(
      "assessor-interface-suitability-record-form-location-field"
    ) ??
    document.getElementById(
      "assessor-interface-suitability-record-form-location-field-error"
    ) ??
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
      onConfirm: openregisterLocationPicker.onConfirm || ((result) => {
        // We get the value entered in the input box
        const input = document.getElementById(locationPicker.id.replace("-select", ""));

        // We remove the existing value on the select so that we don't retain previous selection.
        // This is that with every change, we ensure that the user selects from the dropdown.
        locationPicker.value = '';

        var requestedOption = Array.prototype.filter.call(locationPicker.options, o => o.innerText === input.value)[0]
        if (requestedOption) { requestedOption.selected = true }
      })
    });
  }
};

loadCountryAutoComplete();
dfeAutocomplete({ rawAttribute: true });

checkboxSearchFilter("app-applications-filters-assessor", "Search assessors");

suitabilityRecordForm("app-suitability-record-form");
