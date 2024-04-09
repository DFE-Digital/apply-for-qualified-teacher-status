# frozen_string_literal: true

class FakeData::StaffGenerator
  include ServicePattern

  def call
    RECORDS.each do |record|
      Staff.create!(
        confirmed_at: Time.zone.now,
        password: "password",
        change_email_permission: true,
        **record,
      )
    end
  end

  RECORDS = [
    {
      name: "Dave (assessor)",
      email: "assessor.dave@education.gov.uk",
      assess_permission: true,
    },
    {
      name: "Beryl (assessor)",
      email: "assessor.beryl@education.gov.uk",
      assess_permission: true,
    },
    {
      name: "Jeff (admin)",
      email: "admin.jeff@education.gov.uk",
      verify_permission: true,
    },
    {
      name: "Sally (manager)",
      email: "manager.sally@education.gov.uk",
      change_name_permission: true,
      change_work_history_permission: true,
      reverse_decision_permission: true,
      support_console_permission: true,
      withdraw_permission: true,
    },
    { name: "Antonio (helpdesk)", email: "helpdesk.antonio@education.gov.uk" },
  ].freeze
end
