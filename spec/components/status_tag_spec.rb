# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatusTag::Component, type: :component do
  subject(:component) do
    render_inline(described_class.new(key:, status:, class_context:))
  end

  let(:key) { "key" }
  let(:status) { :awarded }
  let(:class_context) { "app-task-list" }

  describe "text" do
    subject(:text) { component.text.strip }

    it { is_expected.to eq("Awarded") }
  end

  describe "id" do
    subject(:id) { component.at_css("strong")["id"] }

    it { is_expected.to eq("key-status") }
  end

  describe "class" do
    subject(:klass) { component.at_css("strong")["class"] }

    context "with a 'not started' status" do
      let(:status) { :not_started }

      it { is_expected.to eq("govuk-tag govuk-tag--grey app-task-list__tag") }
    end

    context "with an 'in progress' status" do
      let(:status) { :in_progress }

      it { is_expected.to eq("govuk-tag govuk-tag--blue app-task-list__tag") }
    end

    context "with a 'completed' status" do
      let(:status) { :completed }

      it { is_expected.to eq("govuk-tag app-task-list__tag") }
    end

    context "with an 'assessment_in_progress' status" do
      let(:status) { :assessment_in_progress }

      it { is_expected.to eq("govuk-tag govuk-tag--blue app-task-list__tag") }
    end

    context "with an 'awarded' status" do
      let(:status) { :awarded }

      it { is_expected.to eq("govuk-tag govuk-tag--green app-task-list__tag") }
    end

    context "with an 'declined' status" do
      let(:status) { :declined }

      it { is_expected.to eq("govuk-tag govuk-tag--red app-task-list__tag") }
    end

    context "with an 'draft' status" do
      let(:status) { :draft }

      it { is_expected.to eq("govuk-tag govuk-tag--grey app-task-list__tag") }
    end

    context "with an 'submitted' status" do
      let(:status) { :submitted }

      it { is_expected.to eq("govuk-tag govuk-tag--grey app-task-list__tag") }
    end

    context "with an unknown status" do
      let(:status) { :unknown }

      it { is_expected.to eq("govuk-tag app-task-list__tag") }
    end

    context "with a 'rejected' status" do
      let(:status) { :rejected }

      it { is_expected.to eq("govuk-tag govuk-tag--red app-task-list__tag") }
    end
  end
end
