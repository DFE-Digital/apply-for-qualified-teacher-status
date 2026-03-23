import { initAll } from "govuk-frontend";
import dfeAutocomplete from "dfe-autocomplete";

// StimulusJS
import { Application } from "@hotwired/stimulus";
import DisableSubmitController from "./controllers/disable_submit_controller";
import LocationPickerAutocompleteController from "./controllers/location_picker_autocomplete_controller";
import CheckboxSearchFilterController from "./controllers/checkbox_search_filter_controller";
import AppendableTemplateController from "./controllers/appendable_template_controller";
import RemovableElementController from "./controllers/removable_element_controller";

const application = Application.start();

window.Stimulus = application;

application.register("disable-submit", DisableSubmitController);
application.register(
  "location-picker-autocomplete",
  LocationPickerAutocompleteController
);
application.register("checkbox-search-filter", CheckboxSearchFilterController);
application.register("appendable-template", AppendableTemplateController);
application.register("removable-element", RemovableElementController);

initAll();

dfeAutocomplete({ rawAttribute: true });
