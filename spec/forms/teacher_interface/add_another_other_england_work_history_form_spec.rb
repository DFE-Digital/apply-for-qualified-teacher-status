# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::AddAnotherOtherEnglandWorkHistoryForm,
               type: :model do
  subject(:form) { described_class.new }

  it { is_expected.to allow_values(true, false).for(:add_another) }
end
