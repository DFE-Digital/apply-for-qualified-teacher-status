# frozen_string_literal: true

RSpec.shared_examples "a documentable" do
  it "has attachable document types" do
    expect(described_class::ATTACHABLE_DOCUMENT_TYPES).to_not be_nil
  end

  described_class::ATTACHABLE_DOCUMENT_TYPES.each do |document_type|
    it "attaches an empty #{document_type} document" do
      expect(subject.send("#{document_type}_document")).to_not be_nil
    end
  end
end
