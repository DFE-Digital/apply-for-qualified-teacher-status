# frozen_string_literal: true

require "rails_helper"

RSpec.describe MaxTextLengthValidator do
  subject(:model) { Validatable.new }

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :text
      validates :text, max_text_length: true
    end
    model.text = text
    model.valid?
  end

  context "with a text length date" do
    let(:text) { "text" }

    it "has no errors" do
      expect(model.errors[:text]).to be_empty
    end
  end

  context "with exactly 20_000 characters" do
    let(:text) { "text" * 5000 }

    it "has no errors" do
      expect(model.errors[:text]).to be_empty
    end
  end

  context "with more than 20_000 characters" do
    let(:text) { "text" * 5001 }

    it "has an error" do
      expect(model.errors[:text].first).to eq(
        "Response must be 20,000 characters or less",
      )
    end
  end
end
