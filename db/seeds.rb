# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

COUNTRIES = {
  "AU" => [
    {
      name: "Australian Capital Territory",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "New South Wales",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "Northern Territory",
      status_check: "online",
      sanction_check: "online",
    },
    { name: "Queensland", status_check: "online", sanction_check: "online" },
    {
      name: "South Australia",
      status_check: "online",
      sanction_check: "written",
    },
    { name: "Tasmania", status_check: "online", sanction_check: "written" },
    { name: "Victoria", status_check: "online", sanction_check: "online" },
    {
      name: "Western Australia",
      status_check: "online",
      sanction_check: "online",
    },
  ],
  "AT" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Letter of Confirmation",
    },
  ],
  "BE" => [
    {
      name: "Flemish region",
      status_check: "written",
      teaching_authority_certificate: "Certificate of Teaching Qualification",
    },
    {
      name: "French region",
      status_check: "written",
      teaching_authority_certificate:
        "Certificate for the Practice of Teaching",
    },
    { name: "German region", status_check: "written" },
  ],
  "BG" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Teaching Certificate",
    },
  ],
  "CA" => [
    {
      name: "Alberta",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_provides_written_statement: true,
    },
    {
      name: "British Columbia",
      status_check: "online",
      sanction_check: "online",
    },
    { name: "Manitoba", status_check: "written", sanction_check: "written" },
    {
      name: "New Brunswick",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "Newfoundland and Labrador",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "Northwest Territories",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Nova Scotia", status_check: "written", sanction_check: "written" },
    { name: "Nunavut", status_check: "written", sanction_check: "written" },
    { name: "Ontario", status_check: "online", sanction_check: "online" },
    {
      name: "Prince Edward Island",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "Quebec",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Brevet d’enseignement or Teaching Diploma",
    },
    { name: "Saskatchewan", status_check: "online", sanction_check: "online" },
    { name: "Yukon", status_check: "written", sanction_check: "written" },
  ],
  "HR" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Statement of Professional Standing",
    },
  ],
  "CY" => [
    {
      status_check: "written",
      teaching_authority_certificate:
        "Registration on the Waiting List of Teachers",
    },
  ],
  "CZ" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Qualified Teacher Certificate",
    },
  ],
  "DK" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Letter of Recognition",
    },
  ],
  "EE" => [{ status_check: "written", sanction_check: "written" }],
  "FI" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Formal Statement",
    },
  ],
  "FR" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Confirmation of Tenure, Titularisation, Appointment or Internship",
    },
  ],
  "DE" => [
    { name: "Baden-Wurttemberg", status_check: "written" },
    { name: "Bavaria", status_check: "written" },
    { name: "Berlin", status_check: "written", sanction_check: "written" },
    { name: "Brandenburg", status_check: "written" },
    { name: "Bremen", status_check: "written" },
    { name: "Hamburg", status_check: "written" },
    { name: "Hessen", status_check: "written" },
    { name: "Lower Saxony", status_check: "written" },
    { name: "Mecklenburg-Vorpommern", status_check: "written" },
    {
      name: "North Rhine-Westphalia",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Rhineland-Palatinate", status_check: "written" },
    { name: "Saarland", status_check: "written" },
    { name: "Saxony", status_check: "written" },
    { name: "Saxony-Anhalt", status_check: "written" },
    {
      name: "Schleswig-Holstein",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Thuringia", status_check: "written" },
  ],
  "GH" => {
    subject_limited: true,
    regions: [
      {
        requires_preliminary_check: true,
        status_check: "online",
        sanction_check: "online",
        teaching_authority_certificate:
          "letter that proves you’re recognised as a teacher",
      },
    ],
  },
  "GI" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Schedule 3 Certificate of Registration",
    },
  ],
  "GR" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Formal Teacher Certificate",
    },
  ],
  "GG" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Guernsey Qualified Teacher document",
    },
  ],
  "HK" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Statement of Professional Standing",
      teaching_authority_provides_written_statement: true,
    },
  ],
  "HU" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Hatósági Bizonyítvány",
    },
  ],
  "IS" => [
    {
      status_check: "written",
      teaching_authority_certificate: "letter of good standing",
    },
  ],
  "IN" => {
    subject_limited: true,
    regions: [
      {
        requires_preliminary_check: true,
        teaching_authority_certificate:
          "letter that proves you’re recognised as a teacher",
      },
    ],
  },
  "IE" => [
    {
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate: "letter confirming you have no sanctions",
    },
  ],
  "IT" => [
    {
      status_check: "written",
      teaching_authority_certificate:
        "Certificate of Professional Qualification as a Teacher",
    },
  ],
  "JM" => {
    subject_limited: true,
    regions: [
      {
        status_check: "written",
        sanction_check: "written",
        requires_preliminary_check: true,
        teaching_authority_certificate: "Statement of Professional Standing",
      },
    ],
  },
  "JE" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Government of Jersey Certificate",
    },
  ],
  "LV" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Letter of Reference",
    },
  ],
  "LI" => [{ status_check: "written" }],
  "LT" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Formal Letter",
    },
  ],
  "LU" => [{ status_check: "written" }],
  "MT" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Confirmation of Holding of Teachers Warrant",
    },
  ],
  "NL" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Statement of Education",
    },
  ],
  "NZ" => [
    {
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "letter that proves you’re recognised as a teacher",
    },
  ],
  "NG" => {
    subject_limited: true,
    regions: [
      {
        requires_preliminary_check: true,
        status_check: "written",
        sanction_check: "written",
        teaching_authority_provides_written_statement: true,
        teaching_authority_name:
          "Teachers Registration Council of Nigeria (TRCN)",
        teaching_authority_certificate: "Letter of Professional Standing",
      },
    ],
  },
  "GB-NIR" => {
    eligibility_skip_questions: true,
    regions: [
      {
        status_check: "online",
        sanction_check: "written",
        application_form_skip_work_history: true,
        written_statement_optional: true,
        teaching_authority_certificate:
          "Letter of Successful Completion of Induction",
      },
    ],
  },
  "NO" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Official Statement",
    },
  ],
  "PL" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Letter of Confirmation",
    },
  ],
  "PT" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Certificate of Professional Qualification for Teaching",
    },
  ],
  "RO" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate: "Adeverinta",
    },
  ],
  "GB-SCT" => {
    eligibility_skip_questions: true,
    regions: [
      {
        status_check: "online",
        sanction_check: "online",
        application_form_skip_work_history: true,
        teaching_authority_certificate:
          "letter that proves you’re recognised as a teacher",
      },
    ],
  },
  "SG" => {
    subject_limited: true,
    regions: [
      {
        teaching_authority_certificate:
          "letter that proves you’re recognised as a teacher",
      },
    ],
  },
  "SK" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Confirmation of Teaching Competences",
    },
  ],
  "SI" => [
    {
      status_check: "written",
      teaching_authority_certificate: "Confirmation of Teaching Competences",
    },
  ],
  "ZA" => {
    subject_limited: true,
    regions: [
      {
        status_check: "written",
        sanction_check: "written",
        requires_preliminary_check: true,
        teaching_authority_certificate: "Letter of Good Standing",
      },
    ],
  },
  "ES" => [
    {
      status_check: "written",
      teaching_authority_certificate:
        "Certificate of Accreditation (certificado de acreditación profesional)",
    },
  ],
  "SE" => [
    {
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Certification of Qualified Teacher Status",
    },
  ],
  "CH" => [{ status_check: "written", sanction_check: "written" }],
  "UA" => [
    {
      reduced_evidence_accepted: true,
      teaching_authority_certificate:
        "letter that proves you’re recognised as a teacher",
    },
  ],
  "US" => [
    {
      name: "Alabama",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Alaska",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Arizona",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Arkansas",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "California",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Colorado",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Connecticut",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Delaware",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Florida",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Georgia",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Hawaii",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Idaho",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Illinois",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Indiana",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Iowa",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Kansas",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Kentucky",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Louisiana",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Maine",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Maryland",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Massachusetts",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Michigan",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Minnesota",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Mississippi",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Missouri",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Montana",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Nebraska",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Nevada",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "New Hampshire",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "New Jersey",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "New Mexico",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "New York",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "North Carolina",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "North Dakota",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Ohio",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Oklahoma",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Oregon",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Pennsylvania",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Rhode Island",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "South Carolina",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "South Dakota",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Tennessee",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Texas",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Utah",
      status_check: "online",
      sanction_check: "online",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Vermont",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Virginia",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Washington DC",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Washington",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "West Virginia",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Wisconsin",
      status_check: "online",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
    {
      name: "Wyoming",
      status_check: "written",
      sanction_check: "written",
      teaching_authority_certificate:
        "Letter/Statement of Professional Standing",
    },
  ],
  "ZW" => {
    eligibility_enabled: false,
    subject_limited: true,
    regions: [
      {
        status_check: "written",
        teaching_authority_name: "Ministry of Primary and Secondary Education",
        teaching_authority_certificate: "Letter of Good Standing",
      },
    ],
  },
}.freeze

DEFAULT_COUNTRY = { eligibility_enabled: true }.freeze

DEFAULT_REGION = { name: "" }.freeze

COUNTRIES.each do |code, value|
  regions = value.is_a?(Hash) ? value.fetch(:regions, []) : value
  country_hash = value.is_a?(Hash) ? value.except(:regions) : {}

  country =
    Country
      .find_or_initialize_by(code:)
      .tap { |c| c.update!(DEFAULT_COUNTRY.merge(country_hash)) }

  regions << {} if regions.empty?

  regions
    .map { |region| DEFAULT_REGION.merge(region) }
    .each do |region|
      country
        .regions
        .find_or_initialize_by(name: region[:name])
        .update!(region.except(:name))
    end
end

ENGLISH_LANGUAGE_PROVIDERS = [
  {
    name: "IELTS SELT Consortium",
    b2_level_requirement: "5.5",
    b2_level_requirement_prefix: "a score of at least",
    reference_name: "Test Report Form Number",
    reference_hint: "Your Test Report Form Number is 15-18 digits long.",
    accepted_tests:
      "‘International English Language Testing System (IELTS) for " \
        "UK Visa and Immigration (UKVI)’ or ‘International English Language Testing " \
        "System (IELTS) Life Skills'",
    url: "https://www.ielts.org/for-test-takers/book-a-test",
    check_url: "https://ielts.ucles.org.uk/ielts-trf/welcome.html",
  },
  {
    name: "LanguageCert",
    b2_level_requirement: "33/50",
    b2_level_requirement_prefix: "a score of at least",
    reference_name: "Unique Reference Number",
    reference_hint:
      "Your Unique Reference Number contains numbers, letters and dashes " \
        "in this format: PPC/230619/04501/09980013402512496",
    accepted_tests:
      "‘LanguageCert International English for speakers of " \
        "other languages (ESOL) SELT’",
    url: "https://selt.languagecert.org/",
    check_url: "https://www.languagecert.org/en/results",
  },
  {
    name: "Pearson",
    b2_level_requirement: "59",
    b2_level_requirement_prefix: "a score of at least",
    reference_name: "Score Report Code",
    reference_hint:
      "Your Score Report Code is 10 characters long. It may contain both letters " \
        "and numbers, or just numbers.",
    accepted_tests:
      "‘Pearson Test of English (PTE) Academic UK Visa and " \
        "Immigration (UKVI)’ or ‘Pearson Test of English (PTE) Home’",
    url: "https://pearsonpte.com/",
    check_url: "https://srw.pteacademic.com/",
  },
  {
    name: "PSI Services (UK) Ltd",
    b2_level_requirement: "pass",
    b2_level_requirement_prefix: "a",
    reference_name: "Unique Reference Number",
    reference_hint:
      "Your PSI Services (UK) Ltd Unique Reference Number contains numbers, " \
        "letters and dashes in this format: PSI/280920/YTLQVG2Z/W2N4UVNN",
    accepted_tests: "'Skills for English UK Visa and Immigration (UKVI)’",
    url: "https://skillsforenglish.com/",
    check_url: "https://results.bookmyskillsforenglish.com/",
  },
  {
    name: "Trinity College London",
    b2_level_requirement: "pass",
    b2_level_requirement_prefix: "a",
    reference_name: "Certificate Number",
    reference_hint:
      "Your Trinity College London Certificate Number contains numbers, letters " \
        "and special characters in this format: 1-630439614:1-123456780",
    accepted_tests:
      "’Secure English Language Test (SELT) for UK Visa and Immigration (UKVI)’ - " \
        "Integrated Skills in English (ISE) or Graded Examinations in Spoken English (GESE)",
    url: "https://www.trinitycollege.com/qualifications/SELT/UKVI",
    check_url: "https://trinitycollege.com/TRV",
  },
].freeze

ENGLISH_LANGUAGE_PROVIDERS.each do |english_language_provider|
  EnglishLanguageProvider.find_or_initialize_by(
    name: english_language_provider[:name],
  ).update!(english_language_provider.except(:name))
end
