# frozen_string_literal: true

class CountryOfIssueForPassportCode
  PASSPORT_COUNTRY_OF_ISSUE_CODES =
    JSON
      .parse(File.read("public/passport-country-of-issue-canonical-list.json"))
      .map { |row| [row.first, row.last] }
      .to_h

  def self.to_name(code)
    PASSPORT_COUNTRY_OF_ISSUE_CODES[code]
  end
end
