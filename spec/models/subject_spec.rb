# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subject do
  describe "#all" do
    subject(:all) { described_class.all }

    it { is_expected.to_not be_empty }
  end
end
