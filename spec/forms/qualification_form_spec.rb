require "rails_helper"

RSpec.describe QualificationForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end
end
