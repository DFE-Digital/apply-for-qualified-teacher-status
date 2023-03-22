namespace :preliminary_checks do
  desc "Apply 'preliminary_check' status to existing submitted applications"
  task update_submitted_applications: :environment do
    report_only = ENV["PERFORM_UPDATE"] != "true"

    gh_region = Region.find_by(country: Country.find_by(code: "GH"))

    # Unassigned ‘Not started’ or ‘Assessment in progress’ Ghanaian cases
    # submitted from 7 February onwards
    unassigned_gh_scope =
      ApplicationForm.where(
        assessor_id: nil,
        region: gh_region,
        status: %w[submitted initial_assessment],
        submitted_at: Date.new(2023, 2, 7)..Time.zone.today,
      )

    if report_only
      puts "Found #{unassigned_gh_scope.count} unassigned applications for Ghana from 7 Feb 2023 to today"
    else
      unassigned_gh_scope.update_all(status: :preliminary_check)
    end

    # Assigned ‘Not started’ cases from Ghana submitted upto and including 6 February
    assigned_gh_scope =
      ApplicationForm
        .submitted
        .where.not(assessor_id: nil)
        .where(region: gh_region)
        .where("submitted_at < ?", Date.new(2023, 2, 7))

    if report_only
      puts "Found #{assigned_gh_scope.count} assigned applications for Ghana up until and including 6 Feb 2023"
    else
      assigned_gh_scope.update_all(assessor_id: nil)
    end

    ng_region = Region.find_by(country: Country.find_by(code: "NG"))

    # Unassigned ‘Waiting on’ LOPS cases from Nigeria submitted from 23 February onwards
    unassigned_ng_scope =
      ApplicationForm.where(
        assessor_id: nil,
        region: ng_region,
        status: "waiting_on",
        waiting_on_professional_standing: true,
        submitted_at: Date.new(2023, 2, 23)..Time.zone.today,
      )

    if report_only
      puts "Found #{unassigned_ng_scope.count} unassigned applications for Nigeria from 23 Feb 2023 to today"
    else
      unassigned_ng_scope.update_all(status: :preliminary_check)
    end

    # Assigned ‘Waiting for’ LOPs applications from Nigeria received up to and including 22 February
    assigned_ng_scope =
      ApplicationForm
        .submitted
        .where.not(assessor_id: nil)
        .where(region: ng_region, waiting_on_professional_standing: true)
        .where("submitted_at < ?", Date.new(2023, 2, 23))

    if report_only
      puts "Found #{assigned_ng_scope.count} assigned applications for Nigeria up until and including 22 Feb 2023"
    else
      assigned_ng_scope.update_all(assessor_id: nil)
    end
  end
end
