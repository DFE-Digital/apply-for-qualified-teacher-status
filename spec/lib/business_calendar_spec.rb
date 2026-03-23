# frozen_string_literal: true

require "rails_helper"

RSpec.describe Business::Calendar do
  subject(:calendar) { described_class.new(holidays:) }

  let(:holidays) do
    DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date)
  end

  it "has up to date bank holidays" do
    expect(calendar.holidays.max).to be >= Time.zone.today
  end
end
