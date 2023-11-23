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

  desc "Backfill preliminary checks on applications after enabling them."
  task :backfill_preliminary_checks,
       %i[staff_email] => :environment do |_task, args|
    user = Staff.find_by!(email: args[:staff_email])
    count = BackfillPreliminaryChecks.call(user:)
    puts "Updated #{count} applications."
  end

  desc "Update the statuses of all application forms."
  task :update_statuses, %i[staff_email] => :environment do |_task, args|
    user = Staff.find_by!(email: args[:staff_email])
    ApplicationForm
      .order(:id)
      .find_each do |application_form|
        ApplicationFormStatusUpdater.call(application_form:, user:)
        puts "#{application_form.reference}: #{application_form.action_required_by} - #{application_form.status}"
      end
  end
end
