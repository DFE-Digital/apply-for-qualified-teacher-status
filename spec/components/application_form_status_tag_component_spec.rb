# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormStatusTagComponent, type: :component do
  subject(:component) { render_inline(described_class.new(key:, status:)) }

  let(:key) { "key" }
  let(:status) { :status }

  describe "text" do
    subject(:text) { component.text.strip }

    it { is_expected.to eq("Status") }
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
  end
end
