# frozen_string_literal: true

module RegionHelper
  def region_certificate_name(region)
    region.teaching_authority_certificate.presence ||
      "letter that proves you’re recognised as a teacher"
  end

  def region_certificate_phrase(region)
    certificate = region_certificate_name(region)
    "#{certificate.indefinite_article} #{tag.span(certificate, lang: region.country.code)}".html_safe
  end

  def region_teaching_authority_name(region)
    region.teaching_authority_name.presence || "teaching authority"
  end

  def region_teaching_authority_name_phrase(region)
    "the #{region_teaching_authority_name(region)}"
  end

  def region_teaching_authority_emails_phrase(region)
    region
      .teaching_authority_emails
      .map { |email| govuk_link_to email, "mailto:#{email}" }
      .to_sentence
      .html_safe
  end
end
