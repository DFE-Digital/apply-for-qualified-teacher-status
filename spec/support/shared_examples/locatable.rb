# frozen_string_literal: true

RSpec.shared_examples_for "a locatable" do
  describe "#location_note_required?" do
    let(:location_note_required?) { subject.location_note_required? }

    it "returns a boolean" do
      expect(location_note_required?).to be_in([true, false])
    end
  end
end
