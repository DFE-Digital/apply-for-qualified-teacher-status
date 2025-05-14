# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckYourAnswersSummary::Component, type: :component do
  include Rails.application.routes.url_helpers

  subject(:component) do
    render_inline(
      described_class.new(
        id:,
        model:,
        title:,
        fields:,
        changeable:,
        with_action_link_to:,
        with_action_link_label:,
      ),
    )
  end

  let(:id) { "id" }

  let(:model) do
    OpenStruct.new(
      string: "String value",
      number: 10,
      date: Date.new(2020, 1, 1),
      date_without_day: Date.new(2020, 1, 1),
      custom_key: "Custom key value",
      nil_value: nil,
      boolean: true,
      document: create(:document, :with_upload, document_type: :identification),
      array: %w[a b c],
      translatable_document:,
    )
  end

  let(:translatable_document) do
    create(:document, :translatable, :with_translation, :with_upload)
  end

  let(:title) { "Title" }

  let(:fields) do
    {
      string: {
        href: "/string",
      },
      number: {
        href: "/number",
      },
      date: {
        href: "/date",
      },
      date_without_day: {
        format: :without_day,
        href: "/date_without_day",
      },
      custom_key: {
        title: "A custom key",
        href: "/custom_key",
      },
      nil_value: {
        href: "/nil_value",
      },
      boolean: {
        href: "/boolean",
      },
      document: {
        href: "/document",
      },
      array: {
        href: "/array",
      },
      translatable_document: {
        href: "/translatable-document",
      },
    }
  end

  let(:changeable) { true }
  let(:with_action_link_to) { nil }
  let(:with_action_link_label) { nil }

  it "renders the card with an id" do
    expect(component.css(".govuk-summary-card").attribute("id").value).to eq(
      "app-check-your-answers-summary-id",
    )
  end

  it "renders the title" do
    expect(component.css(".govuk-summary-card__title").text).to eq("Title")
  end

  context "with a delete link" do
    let(:with_action_link_to) { "/delete" }
    let(:with_action_link_label) { "Delete" }

    it "renders a link" do
      a = component.at_css(".govuk-summary-card__actions a")
      expect(a.text.strip).to eq("Delete")
      expect(a.attribute("href").value).to eq("/delete")
    end
  end

  context "when changeable is false" do
    subject(:links) do
      component.css(".govuk-summary-list__actions .govuk-link")
    end

    let(:changeable) { false }

    it { is_expected.to be_empty }
  end

  describe "string row" do
    subject(:row) { component.css(".govuk-summary-list__row")[0] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("String")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq(
        "String value",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change string")
      expect(a.attribute("href").value).to eq("/string")
    end
  end

  describe "number row" do
    subject(:row) { component.css(".govuk-summary-list__row")[1] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Number")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq("10")
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change number")
      expect(a.attribute("href").value).to eq("/number")
    end
  end

  describe "date row" do
    subject(:row) { component.css(".govuk-summary-list__row")[2] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Date")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq(
        "1 January 2020",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change date")
      expect(a.attribute("href").value).to eq("/date")
    end
  end

  describe "date without day row" do
    subject(:row) { component.css(".govuk-summary-list__row")[3] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq(
        "Date without day",
      )
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq(
        "January 2020",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change date without day")
      expect(a.attribute("href").value).to eq("/date_without_day")
    end
  end

  describe "custom key row" do
    subject(:row) { component.css(".govuk-summary-list__row")[4] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("A custom key")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq(
        "Custom key value",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change a custom key")
      expect(a.attribute("href").value).to eq("/custom_key")
    end
  end

  describe "nil value row" do
    subject(:row) { component.css(".govuk-summary-list__row")[5] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Nil value")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq(
        "Not provided",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change nil value")
      expect(a.attribute("href").value).to eq("/nil_value")
    end
  end

  describe "boolean row" do
    subject(:row) { component.css(".govuk-summary-list__row")[6] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Boolean")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq("Yes")
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change boolean")
      expect(a.attribute("href").value).to eq("/boolean")
    end
  end

  describe "document row" do
    subject(:row) { component.css(".govuk-summary-list__row")[7] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Document")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value a").text).to eq(
        "upload.pdf (opens in new tab)",
      )
      expect(row.at_css(".govuk-summary-list__value a")[:href]).to eq(
        "/teacher/application/documents/#{model.document.id}/uploads/#{model.document.uploads.last.id}",
      )
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change document")
      expect(a.attribute("href").value).to eq("/document")
    end
  end

  describe "array row" do
    subject(:row) { component.css(".govuk-summary-list__row")[8] }

    it "renders the key" do
      expect(row.at_css(".govuk-summary-list__key").text).to eq("Array")
    end

    it "renders the value" do
      expect(row.at_css(".govuk-summary-list__value").text).to eq("abc")
    end

    it "renders the change link" do
      a = row.at_css(".govuk-summary-list__actions .govuk-link")

      expect(a.text.strip).to eq("Change array")
      expect(a.attribute("href").value).to eq("/array")
    end
  end

  describe "translatable row" do
    describe "original document row" do
      subject(:row) { component.css(".govuk-summary-list__row")[9] }

      it "renders the key" do
        expect(row.at_css(".govuk-summary-list__key").text).to eq(
          "Translatable document",
        )
      end

      it "renders the value" do
        expect(row.at_css(".govuk-summary-list__value a").text).to eq(
          "upload.pdf (opens in new tab)",
        )

        document = model.translatable_document

        expect(row.at_css(".govuk-summary-list__value a")[:href]).to eq(
          "/teacher/application/documents/#{document.id}/uploads/#{document.uploads.last.id}",
        )
      end

      it "renders the change link" do
        a = row.at_css(".govuk-summary-list__actions .govuk-link")

        expect(a.text.strip).to eq("Change translatable document")
        expect(a.attribute("href").value).to eq("/translatable-document")
      end
    end

    describe "translated row" do
      subject(:row) { component.css(".govuk-summary-list__row")[10] }

      it "renders the translation title" do
        expect(row.at_css(".govuk-summary-list__key").text).to eq(
          "Translatable document translation",
        )
      end

      it "renders the value" do
        expect(row.at_css(".govuk-summary-list__value a").text).to eq(
          "upload.pdf (opens in new tab)",
        )

        document = model.translatable_document

        expect(row.at_css(".govuk-summary-list__value a")[:href]).to include(
          "/teacher/application/documents/#{document.id}/uploads/#{document.uploads.first.id}",
        )
      end

      it "renders the change link" do
        a = row.at_css(".govuk-summary-list__actions .govuk-link")

        expect(a.text.strip).to eq("Change translatable document translation")
        expect(a.attribute("href").value).to eq("/translatable-document")
      end
    end

    context "when the translatable document doesn't have any translations" do
      let(:translatable_document) do
        create(:document, :translatable, :with_upload)
      end

      it "does not add a translation row" do
        expect(component).not_to match(/Translatable document translation/)
      end
    end
  end
end
