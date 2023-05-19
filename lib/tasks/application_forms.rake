namespace :application_forms do
  desc "Delete all draft application forms."
  task delete_drafts: :environment do
    puts "This task is destructive! Are you sure you want to continue?"
    $stdin.gets.chomp

    original_count = ApplicationForm.count

    ApplicationForm.draft.each do |application_form|
      DestroyApplicationForm.call(application_form:)
    end

    new_count = ApplicationForm.count

    puts "There were #{original_count} draft applications and there are now #{new_count}."
    puts "There are #{ApplicationForm.count} applications overall."
  end

  desc "Change the contact email address of work history associated with an application."
  task :update_work_history_contact_email,
       %i[reference old_email_address new_email_address] =>
         :environment do |_task, args|
    application_form = ApplicationForm.find_by!(reference: args[:reference])

    UpdateWorkHistoryContactEmail.call(
      application_form:,
      old_email_address: args[:old_email_address],
      new_email_address: args[:new_email_address],
    )
  end
end
