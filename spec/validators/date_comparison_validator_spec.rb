# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateComparisonValidator do
  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :date1, :date2
      validates_with DateComparisonValidator,
                     earlier_field: :date1,
                     later_field: :date2
    end

    stub_const("EqualValidatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :date1, :date2
      validates_with DateComparisonValidator,
                     earlier_field: :date1,
                     later_field: :date2,
                     allow_equal: true
    end
    model.date1 = date1
    model.date2 = date2
    model.valid?
  end

  context "with equal allowed" do
    subject(:model) { Validatable.new }

    context "with valid dates" do
      let(:date1) { { 1 => 2000, 2 => 1, 3 => 1 } }
      let(:date2) { { 1 => 2000, 2 => 1, 3 => 1 } }

      it "has no errors" do
        expect(model.errors[:date]).to be_empty
      end
    end

    context "with invalid dates" do
      let(:date1) { { 1 => 2001, 2 => 1, 3 => 1 } }
      let(:date2) { { 1 => 2000, 2 => 1, 3 => 1 } }

      it "has an error" do
        expect(model.errors[:date2].first).to eq("can't be before start date")
      end
    end
  end

  context "with equal not allowed" do
    subject(:model) { Validatable.new }

    context "with valid dates" do
      let(:date1) { { 1 => 2000, 2 => 1, 3 => 1 } }
      let(:date2) { { 1 => 2001, 2 => 1, 3 => 1 } }

      it "has no errors" do
        expect(model.errors[:date]).to be_empty
      end
    end

    context "with invalid dates" do
      let(:date1) { { 1 => 2001, 2 => 1, 3 => 1 } }
      let(:date2) { { 1 => 2000, 2 => 1, 3 => 1 } }

      it "has an error" do
        expect(model.errors[:date2].first).to eq("can't be before start date")
      end
    end
  end
end
