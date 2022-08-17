class DqtCountryCode
  class << self
    def for_code(code)
      # Cyprus not otherwise specified
      return "XC" if code == "CY"

      # Antarctica and Oceania not otherwise specified
      return "XX" if %w[AQ BAT IO TF HM].include?(code)

      code
    end
  end
end
