import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["submitButton"];

  disableSubmitButton() {
    this.submitButtonTarget.disabled = "disabled";
    this.submitButtonTarget.setAttribute("aria-disabled", "disabled");
  }
}
