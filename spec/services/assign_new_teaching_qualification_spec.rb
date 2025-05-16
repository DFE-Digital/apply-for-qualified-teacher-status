# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignNewTeachingQualification do
  subject(:call) do
    described_class.call(
      current_teaching_qualification:,
      new_teaching_qualification:,
      user:
    )
  end

  let(:qualification) { create(:work_history, :completed) }
  let(:user) { create(:staff) }

  # TODO
end
