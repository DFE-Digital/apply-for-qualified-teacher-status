# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SortBy do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }

  let!(:created_oldest) { create(:application_form, submitted_at: 3.days.ago) }
  let!(:created_middle) { create(:application_form, submitted_at: 2.days.ago) }
  let!(:created_newest) { create(:application_form, submitted_at: 1.day.ago) }

  context "when sort_by is 'submitted_at_asc'" do
    let(:params) { { sort_by: "submitted_at_asc" } }

    it "sorts applications by 'Created oldest to newest'" do
      expect(filtered_scope).to eq(
        [created_oldest, created_middle, created_newest],
      )
    end
  end

  context "when sort_by is 'submitted_at_desc'" do
    let(:params) { { sort_by: "submitted_at_desc" } }

    it "sorts applications by 'Created newest to oldest'" do
      expect(filtered_scope).to eq(
        [created_newest, created_middle, created_oldest],
      )
    end
  end

  context "when sort_by is not provided" do
    let(:params) { {} }

    it "defaults to 'Created newest to oldest'" do
      expect(filtered_scope).to eq(
        [created_newest, created_middle, created_oldest],
      )
    end
  end

  describe "sorting by last updated" do
    before do
      created_oldest.update!(updated_at: 1.day.ago)
      created_middle.update!(updated_at: 3.days.ago)
      created_newest.update!(updated_at: 2.days.ago)
    end

    context "when sort_by is 'last_updated_at_desc'" do
      let(:params) { { sort_by: "last_updated_at_desc" } }

      it "sorts applications by 'Last updated newest to oldest', not by Created on" do
        expect(filtered_scope).to eq(
          [created_oldest, created_newest, created_middle],
        )
      end
    end

    context "when sort_by is 'last_updated_at_asc'" do
      let(:params) { { sort_by: "last_updated_at_asc" } }

      it "sorts applications by 'Last updated oldest to newest', not by Created on" do
        expect(filtered_scope).to eq(
          [created_middle, created_newest, created_oldest],
        )
      end
    end
  end
end
