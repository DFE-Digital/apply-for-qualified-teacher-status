# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FeedbackSubmissionFilterForm do
  subject(:form) { described_class.new(params) }

  let(:params) do
    date_params(after: Date.current - 2.days, before: Date.current - 1.day)
  end

  it { is_expected.to be_valid }

  context "when both dates are blank" do
    let(:params) { {} }

    it "requires both dates" do
      expect(form).to be_invalid
      expect(form.errors.messages).to eq(
        submitted_at_after: ["Enter the date you want to filter from"],
        submitted_at_before: ["Enter the date you want to filter to"],
      )
    end
  end

  %i[day month year].each do |date_part|
    context "when the #{date_part} is missing" do
      let(:params) do
        date_params(
          after: Date.current - 2.days,
          before: Date.current - 1.day,
        ).tap do |values|
          index = { day: 3, month: 2, year: 1 }.fetch(date_part)
          values["submitted_at_after(#{index}i)"] = ""
          values["submitted_at_before(#{index}i)"] = ""
        end
      end

      it "reports the missing #{date_part} for both dates" do
        expect(form).to be_invalid
        expect(form.errors.messages).to eq(
          submitted_at_after: [
            "The date you want to filter from must include a #{date_part}",
          ],
          submitted_at_before: [
            "The date you want to filter to must include a #{date_part}",
          ],
        )
      end
    end
  end

  context "when the dates are not real" do
    let(:params) { date_params(after: [31, 2, 2024], before: [31, 2, 2024]) }

    it "reports both invalid dates" do
      expect(form).to be_invalid
      expect(form.errors.messages).to eq(
        submitted_at_after: [
          "The date you want to filter from must be a real date",
        ],
        submitted_at_before: [
          "The date you want to filter to must be a real date",
        ],
      )
    end
  end

  context "when the dates are in the future" do
    let(:params) do
      date_params(after: Date.current + 1.day, before: Date.current + 2.days)
    end

    it "reports both future dates" do
      expect(form).to be_invalid
      expect(form.errors.messages).to eq(
        submitted_at_after: [
          "The date you want to filter from must be today or in the past",
        ],
        submitted_at_before: [
          "The date you want to filter to must be today or in the past",
        ],
      )
    end
  end

  context "when the to date is before the from date" do
    let(:params) do
      date_params(after: Date.current - 1.day, before: Date.current - 2.days)
    end

    it "reports the invalid date order" do
      expect(form).to be_invalid
      expect(form.errors.messages[:submitted_at_before]).to contain_exactly(
        "The date you want to filter to must be after the date you want to filter from",
      )
    end
  end

  def date_params(after:, before:)
    {
      "submitted_at_after(1i)" => date_part(after, :year),
      "submitted_at_after(2i)" => date_part(after, :month),
      "submitted_at_after(3i)" => date_part(after, :day),
      "submitted_at_before(1i)" => date_part(before, :year),
      "submitted_at_before(2i)" => date_part(before, :month),
      "submitted_at_before(3i)" => date_part(before, :day),
    }
  end

  def date_part(value, part)
    return value.public_send(part).to_s if value.respond_to?(part)

    value.fetch({ day: 0, month: 1, year: 2 }.fetch(part)).to_s
  end
end
