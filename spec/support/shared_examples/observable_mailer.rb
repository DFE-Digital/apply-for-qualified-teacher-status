# frozen_string_literal: true

RSpec.shared_examples "an observable mailer" do |expected_action_name|
  describe "#mailer_class_name" do
    subject(:mailer_class_name) { mail.mailer_class_name }

    it { is_expected.to eq(described_class.name) }
  end

  describe "#mailer_action_name" do
    subject(:mailer_action_name) { mail.mailer_action_name }

    it { is_expected.to eq(expected_action_name) }
  end

  describe "#application_form_id" do
    subject(:application_form_id) { mail.application_form_id }

    it { is_expected.to eq(application_form.id) }
  end
end
