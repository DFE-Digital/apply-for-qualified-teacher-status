require "rails_helper"

module ErrorLog
  RSpec.describe ValidationError, type: :model do
    it { is_expected.to belong_to(:record) }
    it { is_expected.to validate_presence_of(:form_object) }
    it { is_expected.to validate_presence_of(:messages) }
  end
end
