import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["entryTemplate", "entriesContainer"];

  addEntry(event) {
    event.preventDefault();

    let entry = this.entryTemplateTarget.content.cloneNode(true);

    this.entriesContainerTarget.appendChild(entry);
  }

  removeEntry(event) {
    event.preventDefault();
    event.target.previousElementSibling.remove();
    event.target.remove();
  }
}
