class DqtCountryCode
  class << self
    def for_code(code)
      # Cyprus (European Union)
      return "XA" if code == "CY"

      # Cyprus (Non-European Union)
      return "XB" if code == "CY-TR"

      # Antarctica and Oceania not otherwise specified
      return "XX" if %w[AQ BAT IO TF HM].include?(code)

      code
    end
  end
end
