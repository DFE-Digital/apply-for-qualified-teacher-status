import { Controller } from "@hotwired/stimulus";
import "../utils/polyfills";
import outerHeight from "../utils/outer_height";

export default class extends Controller {
  static values = {
    label: String,
  };

  static targets = [
    "container",
    "checkbox",
    "checkboxContainer",
    "checkboxInnerContainer",
  ];

  connect() {
    this.setup();
  }

  filterCheckboxes() {
    var textValue = this.sanitizeText(this.textBox.value);
    var allCheckboxes = this.getAllCheckboxes();

    for (var i = 0; i < allCheckboxes.length; i++) {
      var labelValue = this.sanitizeText(
        allCheckboxes[i].querySelector(".govuk-checkboxes__label").textContent
      );
      if (labelValue.search(textValue) === -1) {
        allCheckboxes[i].style.display = "none";
      } else {
        allCheckboxes[i].style.display = "flex";
      }
    }

    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length,
    });
  }

  getAllCheckboxes() {
    return this.checkboxContainerTarget.querySelectorAll(
      ".govuk-checkboxes__item"
    );
  }

  getAllVisibleCheckboxes() {
    return [].filter.call(this.getAllCheckboxes(), function (el) {
      return el.style.display === "block";
    });
  }

  getAllVisibleCheckedCheckboxes() {
    return [].filter.call(this.getAllVisibleCheckboxes(), function (el) {
      return el.querySelector(".govuk-checkboxes__input").checked;
    });
  }

  getTextBoxHtml() {
    var containerId = this.containerTarget.id;
    var label = document.createElement("label");
    label.setAttribute("for", containerId + "-checkbox-filter__filter-input");
    label.className = "govuk-label govuk-visually-hidden";
    label.innerHTML = this.labelValue;

    var input = document.createElement("input");
    input.className = "app-checkbox-filter__filter-input govuk-input";
    input.setAttribute("id", containerId + "-checkbox-filter__filter-input");
    input.setAttribute("type", "text");
    input.setAttribute("aria-describedby", containerId + "-checkboxes-status");
    input.setAttribute("autocomplete", "off");
    input.setAttribute("spellcheck", "false");

    return [label, input];
  }

  getVisibleCheckboxes() {
    var visibleCheckboxes = [].filter.call(this.checkboxTargets, (el) =>
      this.isCheckboxInView(el)
    );

    // add an extra checkbox, if the label of the first is too long it collapses onto itself
    visibleCheckboxes.push(this.checkboxTargets[visibleCheckboxes.length - 1]);
    return visibleCheckboxes;
  }

  isCheckboxInView(checkbox) {
    var initialOptionContainerHeight =
      this.checkboxContainerTarget.offsetHeight;
    var optionListOffsetTop = this.checkboxInnerContainerTarget.offsetTop;
    var distanceFromTopOfContainer = checkbox.offsetTop - optionListOffsetTop;
    return distanceFromTopOfContainer < initialOptionContainerHeight;
  }

  onTextBoxKeyUp(e) {
    var ENTER_KEY = 13;

    if (e.keyCode === ENTER_KEY) {
      e.preventDefault();
    } else {
      this.filterCheckboxes();
    }
  }

  sanitizeText(text) {
    text = text.replace(/&/g, "and");
    text = text.replace(/[’',:–-]/g, ""); // remove punctuation characters
    text = text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // escape special characters
    return text.trim().replace(/\s\s+/g, " ").toLowerCase(); // replace multiple spaces with one
  }

  setContainerHeight(height) {
    this.checkboxContainerTarget.style.height = height;
  }

  setup() {
    var MIN_FILTERED_CHECKBOX_LENGTH = 2;

    this.setupStatusBox();
    this.setupHeading();
    if (this.checkboxTargets.length >= MIN_FILTERED_CHECKBOX_LENGTH) {
      this.setupTextBox();
    }
    this.setupHeight();
  }

  setupHeading() {
    var element = document.createElement("span");
    element.className = "app-checkbox-filter__title";
    element.setAttribute("aria-hidden", "true");

    this.heading = element;
    this.containerTarget.insertBefore(
      this.heading,
      this.containerTarget.firstChild
    );
  }

  setupHeight() {
    var initialOptionContainerHeight =
      this.checkboxContainerTarget.style.height;
    var height = outerHeight(this.checkboxInnerContainerTarget);

    // check whether this is hidden by progressive disclosure,
    // because height calculations won't work
    if (this.checkboxContainerTarget.offsetParent === null) {
      initialOptionContainerHeight = 200;
      height = 200;
    }

    // Resize if the list is only slightly bigger than its container
    if (height < initialOptionContainerHeight + 50) {
      this.setContainerHeight(height + 1);
      return;
    }

    // Resize to cut last item cleanly in half
    var visibleCheckboxes = this.getVisibleCheckboxes();
    var lastVisibleCheckbox = visibleCheckboxes[visibleCheckboxes.length - 1];
    var position = lastVisibleCheckbox.parentNode.offsetTop; // parent element is relative
    this.setContainerHeight(position + lastVisibleCheckbox.height / 1.5);
  }

  setupStatusBox() {
    var element = document.createElement("div");
    element.className = "govuk-visually-hidden";
    element.id = this.containerTarget.id + "-checkboxes-status";
    element.setAttribute("role", "status");

    this.statusBox = element;
    this.updateStatusBox({
      foundCount: this.getAllVisibleCheckboxes().length,
      checkedCount: this.getAllVisibleCheckedCheckboxes().length,
    });
    this.containerTarget.insertAdjacentElement("afterend", this.statusBox);
  }

  setupTextBox() {
    var tagContainer = this.containerTarget.querySelector(
      ".app-checkbox-filter__selected"
    );
    var textBoxElements = this.getTextBoxHtml();

    if (tagContainer) {
      for (var i = 0; i < textBoxElements.length; i++) {
        tagContainer.parentNode.insertBefore(
          textBoxElements[i],
          tagContainer.nextSibling
        );
      }
    } else {
      for (var i = 0; i < textBoxElements.length; i++) {
        this.heading.parentNode.insertBefore(
          textBoxElements[i],
          this.heading.nextSibling
        );
      }
    }

    this.textBox = this.containerTarget.querySelector(
      ".app-checkbox-filter__filter-input"
    );
    this.textBox.addEventListener("keyup", () => this.onTextBoxKeyUp(this));
  }

  updateStatusBox(params) {
    var status = "%found% options found, %selected% selected";
    status = status.replace(/%found%/, params.foundCount);
    status = status.replace(/%selected%/, params.checkedCount);
    this.statusBox.innerHTML = status;
  }
}
