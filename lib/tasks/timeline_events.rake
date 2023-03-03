namespace :timeline_events do
  desc "Fix missing age range and subjects."
  task fix_age_range_subjects: :environment do
    TimelineEvent.age_range_subjects_verified.find_each do |timeline_event|
      assessment = timeline_event.assessment
      timeline_event.update!(
        age_range_min: assessment.age_range_min,
        age_range_max: assessment.age_range_max,
        age_range_note: assessment.age_range_note,
        subjects: assessment.subjects,
        subjects_note: assessment.subjects_note,
      )
    end
  end
end
