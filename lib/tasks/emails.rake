namespace :emails do
  desc "Backfill the domain column for teachers and work history."
  task backfill_domains: :environment do
    Teacher
      .where(email_domain: "")
      .find_each do |teacher|
        teacher.update!(email_domain: EmailAddress.new(teacher.email).host_name)
      end

    WorkHistory
      .where(contact_email_domain: "")
      .find_each do |work_history|
        work_history.update!(
          contact_email_domain:
            EmailAddress.new(work_history.contact_email).host_name,
        )
      end
  end
end
