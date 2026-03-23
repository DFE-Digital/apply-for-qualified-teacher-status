import { initAll } from "govuk-frontend";
import checkboxSearchFilter from "./checkbox_search_filter";
import dfeAutocomplete from "dfe-autocomplete";
import suitabilityRecordForm from "./suitability_record_form";

// StimulusJS
import { Application } from "@hotwired/stimulus";
import DisableSubmitController from "./controllers/disable_submit_controller";
import LocationPickerAutocompleteController from "./controllers/location_picker_autocomplete_controller";

const application = Application.start();

window.Stimulus = application;

application.register("disable-submit", DisableSubmitController);
application.register(
  "location-picker-autocomplete",
  LocationPickerAutocompleteController
);

initAll();

dfeAutocomplete({ rawAttribute: true });

checkboxSearchFilter("app-applications-filters-assessor", "Search assessors");
checkboxSearchFilter("app-applications-filters-statuses", "Search statuses");

suitabilityRecordForm("app-suitability-record-form");
