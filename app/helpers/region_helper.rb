# frozen_string_literal: true

module RegionHelper
  def region_certificate_phrase(region)
    certificate =
      region.teaching_authority_certificate.presence ||
        region.country.teaching_authority_certificate.presence ||
        "letter that proves you’re recognised as a teacher"
    "#{certificate.indefinite_article} #{tag.span(certificate, lang: region.country.code)}".html_safe
  end

  def region_teaching_authority_name(region)
    region.teaching_authority_name.presence ||
      region.country.teaching_authority_name.presence || "teaching authority"
  end

  def region_teaching_authority_name_phrase(region)
    "the #{region_teaching_authority_name(region)}"
  end

  def region_teaching_authority_emails_phrase(region)
    emails =
      region.teaching_authority_emails +
        region.country.teaching_authority_emails
    emails
      .map { |email| govuk_link_to email, "mailto:#{email}" }
      .to_sentence
      .html_safe
  end
end
