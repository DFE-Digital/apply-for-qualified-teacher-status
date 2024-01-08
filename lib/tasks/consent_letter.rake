# frozen_string_literal: true

namespace :consent_letter do
  desc "Generate a consent letter PDF for a qualification request."
  task :generate, %i[qualification_request_id] => :environment do |_task, args|
    qualification_request =
      QualificationRequest.find(args[:qualification_request_id])

    pdf = ConsentLetter.new(qualification_request:).render_pdf

    File.open("consent-letter.pdf", "wb") { |file| file.write(pdf) }
  end
end
