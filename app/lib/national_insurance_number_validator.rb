# frozen_string_literal: true

class NationalInsuranceNumberValidator
  def initialize(
    national_insurance_number_part_one:,
    national_insurance_number_part_two:,
    national_insurance_number_part_three:
  )
    @national_insurance_number_part_one =
      national_insurance_number_part_one.to_s
    @national_insurance_number_part_two =
      national_insurance_number_part_two.to_s
    @national_insurance_number_part_three =
      national_insurance_number_part_three.to_s
  end

  def valid?
    national_insurance_number_part_one_valid? &&
      national_insurance_number_part_two_valid? &&
      national_insurance_number_part_three_valid?
  end

  def national_insurance_number_part_one_valid?
    national_insurance_number_part_one.to_s.length == 2 &&
      national_insurance_number_part_one.match?(/\A[a-zA-Z]*\z/)
  end

  def national_insurance_number_part_two_valid?
    national_insurance_number_part_two.to_s.length == 6 &&
      national_insurance_number_part_two.match?(/^[0-9]+$/)
  end

  def national_insurance_number_part_three_valid?
    national_insurance_number_part_three.to_s.length == 1 &&
      national_insurance_number_part_three.match?(/\A[a-zA-Z]\z/)
  end

  attr_reader :national_insurance_number_part_one,
              :national_insurance_number_part_two,
              :national_insurance_number_part_three
end
