# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQT::Subject do
  describe "#for" do
    subject(:dqt_code) { described_class.for(value) }

    shared_examples "DQT code" do |value|
      let(:value) { value }
      it { is_expected.to_not be_nil }
    end

    Subject.all.map { |subject| it_behaves_like "DQT code", subject.value }
  end
end
