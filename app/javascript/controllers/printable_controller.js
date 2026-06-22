import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  printPage(event) {
    event.preventDefault();

    window.print();
  }
}
