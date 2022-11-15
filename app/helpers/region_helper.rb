# frozen_string_literal: true

module RegionHelper
  def region_certificate_phrase(region)
    certificate =
      region.teaching_authority_certificate.presence ||
        region.country.teaching_authority_certificate.presence ||
        "letter that proves you’re recognised as a teacher"
    "#{certificate.indefinite_article} #{tag.span(certificate, lang: region.country.code)}".html_safe
  end
end
