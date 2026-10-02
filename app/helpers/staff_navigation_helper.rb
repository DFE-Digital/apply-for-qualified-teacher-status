# frozen_string_literal: true

module StaffNavigationHelper
  def staff_navigation_sections
    unless current_staff && current_namespace.in?(%w[assessor support])
      return []
    end

    [
      {
        text: "Applications",
        href: main_app.assessor_interface_application_forms_path,
        items: [],
      },
      {
        text: "Records",
        items: [
          if FeatureFlags::FeatureFlag.active?(:suitability)
            {
              text: "Suitability records",
              href: main_app.assessor_interface_suitability_records_path,
            }
          end,
          if AssessorInterface::EligibilityDomainPolicy.new(
               current_staff,
               EligibilityDomain,
             ).index?
            {
              text: "Email domain records",
              href: main_app.assessor_interface_eligibility_domains_path,
            }
          end,
        ].compact,
      },
      {
        text: "Monitoring",
        items: [
          if AssessorInterface::EmailDeliveryPolicy.new(
               current_staff,
               EmailDelivery,
             ).index?
            {
              text: "Email failures",
              href: main_app.assessor_interface_email_delivery_failures_path,
            }
          end,
          if AssessorInterface::ServiceLevelAgreementPolicy.new(
               current_staff,
               :service_level_agreement,
             ).index?
            {
              text: "SLA status",
              href: main_app.assessor_interface_service_level_agreements_path,
            }
          end,
          if AssessorInterface::FeedbackSubmissionPolicy.new(
               current_staff,
               :feedback_submission,
             ).index?
            {
              text: "Service feedback",
              href: main_app.assessor_interface_feedback_submissions_path,
            }
          end,
        ].compact,
      },
      {
        text: "Support console",
        items: [
          if SupportInterface::CountryPolicy.new(current_staff, Country).index?
            {
              text: "Countries",
              href: main_app.support_interface_countries_path,
              match: %w[/support/countries /support/regions],
            }
          end,
          if SupportInterface::CountryPolicy.new(current_staff, Country).index?
            {
              text: "English language test providers",
              href: main_app.support_interface_english_language_providers_path,
            }
          end,
          if AssessorInterface::StaffPolicy.new(current_staff, Staff).index?
            {
              text: "Manage access",
              href: main_app.assessor_interface_staff_index_path,
            }
          end,
        ].compact,
      },
      {
        text: "Developer tools",
        items: [
          if SupportInterface::FeatureFlagPolicy.new(
               current_staff,
               :feature_flag,
             ).index?
            {
              text: "Features",
              href: main_app.support_interface_feature_flags_path,
            }
          end,
          if SupportInterface::FeatureFlagPolicy.new(
               current_staff,
               :feature_flag,
             ).index?
            {
              text: "Solid queue",
              href: main_app.support_interface_mission_control_jobs_path,
              new_tab: true,
            }
          end,
        ].compact,
      },
    ].reject { |section| section[:href].nil? && section[:items].empty? }
  end

  def staff_navigation_item_active?(item)
    Array(item[:match] || item[:href]).any? do |path|
      request.path.start_with?(path)
    end
  end

  def current_staff_navigation_section(sections)
    sections.find do |section|
      staff_navigation_item_active?(section) ||
        section[:items].any? { |item| staff_navigation_item_active?(item) }
    end
  end
end
