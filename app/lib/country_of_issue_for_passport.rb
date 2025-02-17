# frozen_string_literal: true

class CountryOfIssueForPassport
  CANONICAL_LIST =
    JSON.parse(
      File.read("public/passport-country-of-issue-canonical-list.json"),
    )

  CODE_TO_NAME_MAPPING = CANONICAL_LIST.map { |row| [row.last, row.first] }.to_h

  def self.to_name(code)
    CODE_TO_NAME_MAPPING[code]
  end
end
