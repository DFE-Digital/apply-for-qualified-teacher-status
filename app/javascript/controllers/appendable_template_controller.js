import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template", "container"];

  append(event) {
    event.preventDefault();

    let entry = this.templateTarget.content.cloneNode(true);

    this.containerTarget.appendChild(entry);
  }
}
