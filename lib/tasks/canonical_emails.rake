# frozen_string_literal: true

namespace :canonical_emails do
  desc "Update the canonical email address for each teacher."
  task update_teachers: :environment do
    Teacher.find_each do |teacher|
      teacher.update!(canonical_email: EmailAddress.canonical(teacher.email))
    end
  end

  desc "Update the canonical email address for each work history."
  task update_work_histories: :environment do
    WorkHistory.find_each do |work_history|
      work_history.update!(
        canonical_contact_email:
          EmailAddress.canonical(work_history.contact_email),
      )
    end
  end

  desc "Update the canonical email addresses."
  task update: %i[update_teachers update_work_histories]
end
