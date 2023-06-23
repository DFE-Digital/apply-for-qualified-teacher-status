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

  desc "Withdraw an application which has not yet been awarded or declined."
  task :withdraw, %i[reference staff_email] => :environment do |_task, args|
    application_form =
      ApplicationForm.assessable.find_by!(reference: args[:reference])
    user = Staff.find_by!(email: args[:staff_email])

    WithdrawApplicationForm.call(application_form:, user:)
  end

  desc "Turn on preliminary checks for draft or submitted applications."
  task :enable_preliminary_checks,
       %i[country_code staff_email] => :environment do |_task, args|
    application_forms =
      ApplicationForm.joins(region: :country).where(
        requires_preliminary_check: false,
        status: %w[draft submitted],
        countries: {
          code: args[:country_code],
        },
      )

    puts "This will change #{application_forms.count} applications. Are you sure you want to continue?"
    $stdin.gets.chomp

    user = Staff.find_by!(email: args[:staff_email])

    application_forms.find_each do |application_form|
      application_form.update!(requires_preliminary_check: true)
      ApplicationFormStatusUpdater.call(application_form:, user:)
      puts "#{application_form.reference}: #{application_form.status}"
    end
  end

  desc "Update status of application forms in waiting on to overdue"
  task update_waiting_on_applications: :environment do
    user = "Expirer"
    assessment_ids = ReferenceRequest.expired.select(:assessment_id)
    ApplicationForm
      .waiting_on
      .joins(:assessment)
      .where(assessment: { id: assessment_ids })
      .each do |application_form|
        ApplicationFormStatusUpdater.call(application_form:, user:)
      end
  end
end
