# frozen_string_literal: true

namespace :emails do
  namespace :application_not_submitted do
    namespace :two_weeks_before do
      desc "Send the application not submitted email for two weeks before to all teachers."
      task send_all: :environment do
        send_application_not_submitted_emails(
          Teacher.with_draft_application_forms,
          "two_weeks",
        )
      end

      desc "Send the application not submitted email for two weeks before to one teachers."
      task :send_one, [:email] => :environment do |_, args|
        send_application_not_submitted_emails(
          Teacher.find_by!(email: args[:email]),
          "two_weeks",
        )
      end
    end

    namespace :one_week_before do
      desc "Send the application not submitted email for one week before to all teachers."
      task send_all: :environment do
        send_application_not_submitted_emails(
          Teacher.with_draft_application_forms,
          "one_week",
        )
      end

      desc "Send the application not submitted email for one week before to one teachers."
      task :send_one, [:email] => :environment do |_, args|
        send_application_not_submitted_emails(
          Teacher.find_by!(email: args[:email]),
          "one_week",
        )
      end
    end

    namespace :two_days_before do
      desc "Send the application not submitted email for two days before to all teachers."
      task send_all: :environment do
        send_application_not_submitted_emails(
          Teacher.with_draft_application_forms,
          "two_days",
        )
      end

      desc "Send the application not submitted email for two days before to one teachers."
      task :send_one, [:email] => :environment do |_, args|
        send_application_not_submitted_emails(
          Teacher.find_by!(email: args[:email]),
          "two_days",
        )
      end
    end
  end
end

def send_application_not_submitted_emails(teachers, duration)
  teachers = [teachers] if teachers.is_a?(Teacher)

  teachers.each do |teacher|
    TeacherMailer
      .with(teacher:, duration:)
      .application_not_submitted
      .deliver_later
  end
end
