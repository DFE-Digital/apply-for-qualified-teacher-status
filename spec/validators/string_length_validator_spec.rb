# frozen_string_literal: true

require "rails_helper"

RSpec.describe StringLengthValidator do
  subject(:model) { Validatable.new }

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :string
      validates :string, string_length: true
    end
    model.string = string
    model.valid?
  end

  context "with a string length date" do
    let(:string) { "text" }

    it "has no errors" do
      expect(model.errors[:string]).to be_empty
    end
  end

  context "with exactly 1000 characters" do
    let(:string) { "text" * 250 }

    it "has no errors" do
      expect(model.errors[:string]).to be_empty
    end
  end

  context "with more than 1000 characters" do
    let(:string) { "text" * 251 }

    it "has an error" do
      expect(model.errors[:string].first).to eq(
        "Response must be 1,000 characters or less",
      )
    end
  end
end
