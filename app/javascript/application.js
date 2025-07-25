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
      "teacher-interface-other-england-work-history-school-form-country-location-field"
    ) ??
    document.getElementById(
      "teacher-interface-other-england-work-history-school-form-country-location-field-error"
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

var loadPassportCountryOfIssueAutoComplete = () => {
  var passportCountryOfIssuePicker =
    document.getElementById(
      "teacher-interface-passport-expiry-date-form-passport-country-of-issue-code-field"
    ) ??
    document.getElementById(
      "teacher-interface-passport-expiry-date-form-passport-country-of-issue-code-field-error"
    );

  if (passportCountryOfIssuePicker) {
    openregisterLocationPicker({
      selectElement: passportCountryOfIssuePicker,
      url: "/autocomplete_passport_country_of_issues.json",
      name: "passport_country_of_issue_autocomplete",
    });
  }
};

loadCountryAutoComplete();
loadPassportCountryOfIssueAutoComplete();
dfeAutocomplete({ rawAttribute: true });

checkboxSearchFilter("app-applications-filters-assessor", "Search assessors");
checkboxSearchFilter("app-applications-filters-statuses", "Search statuses");

suitabilityRecordForm("app-suitability-record-form");
