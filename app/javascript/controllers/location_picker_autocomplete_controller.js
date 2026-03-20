import { Controller } from "@hotwired/stimulus";
import dfeAutocomplete from "dfe-autocomplete";
import openregisterLocationPicker from "govuk-country-and-territory-autocomplete";

export default class extends Controller {
  static values = {
    url: String,
    name: String,
  };

  connect() {
    openregisterLocationPicker({
      selectElement: this.element,
      url: this.urlValue,
      name: this.nameValue,
    });

    dfeAutocomplete({ rawAttribute: true });
  }
}
