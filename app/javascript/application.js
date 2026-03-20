import { initAll } from "govuk-frontend";
import checkboxSearchFilter from "./checkbox_search_filter";
import suitabilityRecordForm from "./suitability_record_form";

// StimulusJS
import { Application } from "@hotwired/stimulus";
import DisableSubmitController from "./controllers/disable_submit_controller";
import CountriesTerritoriesAutocompleteController from "./controllers/countries_territories_autocomplete_controller";
import PassportCountriesOfIssueAutocompleteController from "./controllers/passport_countries_of_issue_autocomplete_controller";

const application = Application.start();

window.Stimulus = application;

application.register("disable-submit", DisableSubmitController);
application.register(
  "countries-territories-autocomplete",
  CountriesTerritoriesAutocompleteController
);
application.register(
  "passport-countries-of-issue-autocomplete",
  PassportCountriesOfIssueAutocompleteController
);

initAll();

checkboxSearchFilter("app-applications-filters-assessor", "Search assessors");
checkboxSearchFilter("app-applications-filters-statuses", "Search statuses");

suitabilityRecordForm("app-suitability-record-form");
