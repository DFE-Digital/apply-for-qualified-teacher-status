# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DeclarationDecisionReviewRequestForm,
               type: :model do
  subject(:form) { described_class.new(confirm:) }

  describe "validations" do
    let(:confirm) { "" }

    it { is_expected.to validate_presence_of(:confirm) }
  end
end
