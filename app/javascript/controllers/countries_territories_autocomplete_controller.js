import { Controller } from "@hotwired/stimulus";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

export default class extends Controller {
  connect() {
    openregisterLocationPicker({
      selectElement: this.element,
      url: "/autocomplete_locations.json",
      name: "location_autocomplete",
    });
  }
}
