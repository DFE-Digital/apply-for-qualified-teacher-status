# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateValidator do
  subject(:model) { Validatable.new }

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :date
      validates :date, date: true
    end
    model.date = date
    model.valid?
  end

  context "with a valid date" do
    let(:date) { { 1 => 2000, 2 => 1, 3 => 1 } }

    it "has no errors" do
      expect(model.errors[:date]).to be_empty
    end
  end

  context "with missing values" do
    let(:date) { { 1 => 2000, 3 => 1 } }

    it "has an error" do
      expect(model.errors[:date].first).to eq("can't be blank")
    end
  end

  context "with an invalid year" do
    let(:date) { { 1 => 90, 2 => 1, 3 => 1 } }

    it "has an error" do
      expect(model.errors[:date].first).to eq("is invalid")
    end
  end

  context "with an invalid date" do
    let(:date) { { 1 => 2000, 2 => 13, 3 => 1 } }

    it "has an error" do
      expect(model.errors[:date].first).to eq("is invalid")
    end
  end

  context "with a future date" do
    let(:date) { { 1 => 3000, 2 => 1, 3 => 1 } }

    it "has an error" do
      expect(model.errors[:date].first).to eq("can't be in the future")
    end
  end
end
