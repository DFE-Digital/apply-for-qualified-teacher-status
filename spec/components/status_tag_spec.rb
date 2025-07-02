# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatusTag::Component, type: :component do
  subject(:component) do
    render_inline(described_class.new(status, id:, class_context:))
  end

  let(:id) { "id" }
  let(:status) { :awarded }
  let(:class_context) { "app-task-list" }

  describe "text" do
    subject(:text) { component.text.strip }

    it { is_expected.to eq("Awarded") }
  end

  describe "id" do
    subject { component.at_css("strong")["id"] }

    it { is_expected.to eq("id") }
  end

  describe "class" do
    subject(:klass) { component.at_css("strong")["class"] }

    context "with a 'not started' status" do
      let(:status) { :not_started }

      it { is_expected.to eq("govuk-tag govuk-tag--grey") }
    end

    context "with an 'in progress' status" do
      let(:status) { :in_progress }

      it { is_expected.to eq("govuk-tag govuk-tag--blue") }
    end

    context "with a 'completed' status" do
      let(:status) { :completed }

      it { is_expected.to eq("govuk-tag govuk-tag--green") }
    end

    context "with an 'assessment_in_progress' status" do
      let(:status) { :assessment_in_progress }

      it { is_expected.to eq("govuk-tag govuk-tag--blue") }
    end

    context "with an 'awarded' status" do
      let(:status) { :awarded }

      it { is_expected.to eq("govuk-tag govuk-tag--green") }
    end

    context "with an 'declined' status" do
      let(:status) { :declined }

      it { is_expected.to eq("govuk-tag govuk-tag--red") }
    end

    context "with an 'draft' status" do
      let(:status) { :draft }

      it { is_expected.to eq("govuk-tag govuk-tag--grey") }
    end

    context "with an 'submitted' status" do
      let(:status) { :submitted }

      it { is_expected.to eq("govuk-tag govuk-tag--grey") }
    end

    context "with an unknown status" do
      let(:status) { :unknown }

      it { is_expected.to eq("govuk-tag") }
    end

    context "with a 'rejected' status" do
      let(:status) { :rejected }

      it { is_expected.to eq("govuk-tag govuk-tag--red") }
    end

    context "with a 'withdrawn' status" do
      let(:status) { :withdrawn }

      it { is_expected.to eq("govuk-tag govuk-tag--red") }
    end
  end
end
