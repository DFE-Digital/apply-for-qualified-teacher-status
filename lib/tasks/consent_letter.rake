# frozen_string_literal: true

namespace :consent_letter do
  desc "Generate a consent letter PDF for a qualification request."
  task :generate,
       %i[application_form_reference] => :environment do |_task, args|
    application_form =
      ApplicationForm.find_by!(reference: args[:application_form_reference])

    pdf = ConsentLetter.new(application_form:).render_pdf

    File.open("consent-letter.pdf", "wb") { |file| file.write(pdf) }
  end
end
