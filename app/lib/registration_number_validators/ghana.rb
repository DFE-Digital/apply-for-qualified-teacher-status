# frozen_string_literal: true

module RegistrationNumberValidators
  class Ghana
    def initialize(registration_number:)
      @registration_number = registration_number

      registration_number_parts = registration_number.split("/")

      @license_number_part_one = registration_number_parts[0]
      @license_number_part_two = registration_number_parts[1]
      @license_number_part_three = registration_number_parts[2]
    end

    def valid?
      license_number_part_one_valid? &&
      license_number_part_two_valid? &&
      license_number_part_three_valid?
    end

    def license_number_part_one_valid?
      license_number_part_one.to_s.length == 2 &&
        license_number_part_one.match?(/\A[a-zA-Z]*\z/)
    end

    def license_number_part_two_valid?
      license_number_part_two.to_s.length == 6 &&
        license_number_part_two.match?(/^[0-9]+$/)
    end

    def license_number_part_three_valid?
      license_number_part_three.to_s.length == 4 &&
        license_number_part_three.match?(/^[0-9]+$/)
    end

    private

    attr_reader :license_number_part_one, :license_number_part_two, :license_number_part_three
  end
end
