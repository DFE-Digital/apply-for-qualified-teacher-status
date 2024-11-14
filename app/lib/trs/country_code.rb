# frozen_string_literal: true

class TRS::CountryCode
  class << self
    def for_code(code)
      # Cyprus (European Union)
      return "XA" if code == "CY"

      # Cyprus (Non-European Union)
      return "XB" if code == "CY-TR"

      # Antarctica and Oceania not otherwise specified
      return "XX" if %w[AQ BAT IO TF HM].include?(code)

      # England
      return "XF" if code == "GB-ENG"

      # Wales
      return "XI" if code == "GB-WLS"

      # Scotland
      return "XH" if code == "GB-SCT"

      # Northern Ireland
      return "XG" if code == "GB-NIR"

      code
    end
  end
end
