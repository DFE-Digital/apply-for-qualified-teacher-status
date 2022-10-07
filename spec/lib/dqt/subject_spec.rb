# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQT::Subject do
  describe "#for_id" do
    subject(:dqt_code) { described_class.for_id(id) }

    shared_examples "DQT code" do |id|
      let(:id) { id }
      it { is_expected.to_not be_nil }
    end

    Subject.all.map { |subject| it_behaves_like "DQT code", subject.id }
  end
end
