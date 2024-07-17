function SuitabilityRecordForm(params) {
  this.params = params;
  this.form = params.form;

  this.setUp = function (name, addButton, removeButtons, container, input) {
    addButton.addEventListener(
      "click",
      function (event) {
        let newElement = input.cloneNode(true);
        newElement.querySelector("input").value = "";
        container.appendChild(newElement);

        let removeButton = document.createElement("a");
        removeButton.href = "#";
        removeButton.className = "govuk-button govuk-button--secondary";
        removeButton.innerText = "Remove " + name;
        removeButton.addEventListener(
          "click",
          function (event) {
            newElement.remove();
            removeButton.remove();
            event.preventDefault();
          },
          false
        );
        container.appendChild(removeButton);

        event.preventDefault();
      },
      false
    );

    removeButtons.forEach(function (button) {
      button.addEventListener(
        "click",
        function () {
          button.previousElementSibling.remove();
          button.remove();
          event.preventDefault();
        },
        false
      );
    });
  };

  this.aliasAddButton = this.form.querySelector("#app-add-alias-button");
  this.aliasRemoveButtons = this.form.querySelectorAll(
    ".app-remove-alias-button"
  );
  this.aliasContainer = this.form.querySelector("#app-aliases");
  this.aliasInput = this.form.querySelector(
    "[name='assessor_interface_suitability_record_form[aliases][]']"
  ).parentElement;

  this.setUp(
    "alias",
    this.aliasAddButton,
    this.aliasRemoveButtons,
    this.aliasContainer,
    this.aliasInput
  );

  this.emailAddButton = this.form.querySelector("#app-add-email-button");
  this.emailRemoveButtons = this.form.querySelectorAll(
    ".app-remove-email-button"
  );
  this.emailContainer = this.form.querySelector("#app-emails");
  this.emailInput = this.form.querySelector(
    "[name='assessor_interface_suitability_record_form[emails][]']"
  ).parentElement;

  this.setUp(
    "email address",
    this.emailAddButton,
    this.emailRemoveButtons,
    this.emailContainer,
    this.emailInput
  );

  this.referenceAddButton = this.form.querySelector(
    "#app-add-reference-button"
  );
  this.referenceRemoveButtons = this.form.querySelectorAll(
    ".app-remove-reference-button"
  );
  this.referenceContainer = this.form.querySelector("#app-references");
  this.referenceInput = this.form.querySelector(
    "[name='assessor_interface_suitability_record_form[references][]']"
  ).parentElement;

  this.setUp(
    "application reference number",
    this.referenceAddButton,
    this.referenceRemoveButtons,
    this.referenceContainer,
    this.referenceInput
  );
}

function suitabilityRecordForm(formId) {
  let formElement = document.getElementById(formId);

  if (formElement) {
    return new SuitabilityRecordForm({
      form: formElement,
    });
  }
}

export default suitabilityRecordForm;
