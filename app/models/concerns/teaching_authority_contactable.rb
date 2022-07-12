module TeachingAuthorityContactable
  extend ActiveSupport::Concern

  def teaching_authority_emails_string
    teaching_authority_emails.join("\n")
  end

  def teaching_authority_emails_string=(string)
    self.teaching_authority_emails =
      string.split("\n").map(&:chomp).compact_blank
  end

  def teaching_authority_websites_string
    teaching_authority_websites.join("\n")
  end

  def teaching_authority_websites_string=(string)
    self.teaching_authority_websites =
      string.split("\n").map(&:chomp).compact_blank
  end

  def teaching_authority_present?
    teaching_authority_address.present? || teaching_authority_emails.present? ||
      teaching_authority_websites.present?
  end
end
