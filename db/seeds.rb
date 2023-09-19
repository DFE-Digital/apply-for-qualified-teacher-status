# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

COUNTRIES = {
  "BE" => [
    { name: "Flemish region", status_check: "none", sanction_check: "none" },
    { name: "French region", status_check: "none", sanction_check: "none" },
    { name: "German region", status_check: "none", sanction_check: "none" },
  ],
  "CZ" => [{ status_check: "written" }],
  "EE" => [{ status_check: "written", sanction_check: "written" }],
  "FR" => [{ status_check: "written", sanction_check: "written" }],
  "IS" => [{ status_check: "written" }],
  "LV" => [{ status_check: "written", sanction_check: "written" }],
  "LI" => [{ status_check: "written" }],
  "LU" => [{ status_check: "written" }],
  "MT" => [{ status_check: "written", sanction_check: "written" }],
  "SI" => [{ status_check: "written" }],
  "NZ" => [{ status_check: "online", sanction_check: "online" }],
  "GI" => [{ status_check: "written", sanction_check: "written" }],
  "GB-SCT" => {
    eligibility_skip_questions: true,
    regions: [
      {
        status_check: "online",
        sanction_check: "online",
        application_form_skip_work_history: true,
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
      },
    ],
  },
  "AT" => [{ status_check: "written" }],
  "CH" => [{ status_check: "written", sanction_check: "written" }],
  "GR" => [],
  "US" => [
    { name: "Kentucky", status_check: "written", sanction_check: "written" },
    { name: "Mississippi", status_check: "written", sanction_check: "written" },
    { name: "Maryland", status_check: "written", sanction_check: "written" },
    { name: "Nevada", status_check: "online", sanction_check: "written" },
    { name: "Iowa", status_check: "online", sanction_check: "online" },
    { name: "Massachusetts", status_check: "online", sanction_check: "online" },
    { name: "Michigan", status_check: "online", sanction_check: "online" },
    { name: "Missouri", status_check: "online", sanction_check: "online" },
    { name: "New York", status_check: "online", sanction_check: "online" },
    {
      name: "North Carolina",
      status_check: "online",
      sanction_check: "online",
    },
    { name: "Oklahoma", status_check: "online", sanction_check: "online" },
    { name: "Oregon", status_check: "online", sanction_check: "online" },
    { name: "Pennsylvania", status_check: "online", sanction_check: "online" },
    { name: "Tennessee", status_check: "online", sanction_check: "online" },
    { name: "Texas", status_check: "online", sanction_check: "online" },
    { name: "Utah", status_check: "online", sanction_check: "online" },
    { name: "Washington", status_check: "written", sanction_check: "written" },
    {
      name: "Washington DC",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Maine", status_check: "written", sanction_check: "written" },
    { name: "Wyoming", status_check: "written", sanction_check: "written" },
    { name: "North Dakota", status_check: "online", sanction_check: "written" },
    { name: "South Dakota", status_check: "online", sanction_check: "written" },
    { name: "Nebraska", status_check: "online", sanction_check: "online" },
    { name: "New Mexico", status_check: "written", sanction_check: "written" },
    { name: "Alabama", status_check: "written", sanction_check: "written" },
    { name: "Hawaii", status_check: "online", sanction_check: "online" },
    { name: "Colorado", status_check: "online", sanction_check: "online" },
    { name: "Alaska", status_check: "online", sanction_check: "online" },
    { name: "Arkansas", status_check: "online", sanction_check: "online" },
    { name: "California", status_check: "online", sanction_check: "online" },
    { name: "Delaware", status_check: "online", sanction_check: "online" },
    { name: "Florida", status_check: "online", sanction_check: "online" },
    { name: "Georgia", status_check: "online", sanction_check: "online" },
    { name: "Idaho", status_check: "online", sanction_check: "online" },
    { name: "Illinois", status_check: "online", sanction_check: "online" },
    { name: "Louisiana", status_check: "online", sanction_check: "online" },
    { name: "Indiana", status_check: "written", sanction_check: "written" },
    { name: "Connecticut", status_check: "written", sanction_check: "written" },
    {
      name: "West Virginia",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Minnesota", status_check: "online", sanction_check: "written" },
    {
      name: "New Hampshire",
      status_check: "online",
      sanction_check: "written",
    },
    { name: "Rhode Island", status_check: "online", sanction_check: "written" },
    { name: "Vermont", status_check: "online", sanction_check: "written" },
    { name: "Virginia", status_check: "online", sanction_check: "written" },
    { name: "Wisconsin", status_check: "online", sanction_check: "written" },
    { name: "Arizona", status_check: "written", sanction_check: "written" },
    { name: "Kansas", status_check: "written", sanction_check: "written" },
    { name: "Montana", status_check: "written", sanction_check: "written" },
    { name: "Ohio", status_check: "written", sanction_check: "written" },
    {
      name: "South Carolina",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "New Jersey", status_check: "online", sanction_check: "written" },
  ],
  "HU" => [{ status_check: "written" }],
  "DE" => [
    {
      name: "North Rhine-Westphalia",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Lower Saxony", status_check: "written", sanction_check: "none" },
    {
      name: "Baden-Wurttemberg",
      status_check: "written",
      sanction_check: "none",
    },
    { name: "Bremen", status_check: "written", sanction_check: "none" },
    { name: "Hessen", status_check: "written", sanction_check: "none" },
    { name: "Saxony-Anhalt", status_check: "written", sanction_check: "none" },
    { name: "Saarland", status_check: "written", sanction_check: "none" },
    { name: "Berlin", status_check: "written", sanction_check: "written" },
    { name: "Brandenburg", status_check: "written", sanction_check: "none" },
    { name: "Bavaria", status_check: "written", sanction_check: "none" },
    {
      name: "Schleswig-Holstein",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Hamburg", status_check: "written", sanction_check: "none" },
    { name: "Saxony", status_check: "written", sanction_check: "none" },
    {
      name: "Mecklenburg-Vorpommern",
      status_check: "written",
      sanction_check: "none",
    },
    {
      name: "Rhineland-Palatinate",
      status_check: "written",
      sanction_check: "none",
    },
    { name: "Thuringia", status_check: "written", sanction_check: "none" },
  ],
  "HR" => [{ status_check: "written" }],
  "BG" => [{ status_check: "written", sanction_check: "written" }],
  "NL" => [{ status_check: "written" }],
  "IT" => [{ status_check: "written" }],
  "PL" => [{ status_check: "written", sanction_check: "written" }],
  "IE" => [{ status_check: "online", sanction_check: "written" }],
  "ES" => [{ status_check: "written" }],
  "AU" => [
    {
      name: "New South Wales",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "South Australia",
      status_check: "online",
      sanction_check: "written",
    },
    {
      name: "Australian Capital Territory",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Queensland", status_check: "online", sanction_check: "online" },
    { name: "Victoria", status_check: "online", sanction_check: "online" },
    {
      name: "Northern Territory",
      status_check: "online",
      sanction_check: "online",
    },
    {
      name: "Western Australia",
      status_check: "online",
      sanction_check: "online",
    },
    { name: "Tasmania", status_check: "online", sanction_check: "written" },
  ],
  "CA" => [
    { name: "Manitoba", status_check: "written", sanction_check: "written" },
    {
      name: "Newfoundland and Labrador",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "New Brunswick",
      status_check: "written",
      sanction_check: "written",
    },
    {
      name: "Northwest Territories",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Nova Scotia", status_check: "written", sanction_check: "written" },
    {
      name: "Prince Edward Island",
      status_check: "written",
      sanction_check: "written",
    },
    { name: "Quebec", status_check: "written", sanction_check: "written" },
    { name: "Alberta", status_check: "written", sanction_check: "written" },
    {
      name: "British Columbia",
      status_check: "online",
      sanction_check: "online",
    },
    { name: "Ontario", status_check: "online", sanction_check: "online" },
    { name: "Saskatchewan", status_check: "online", sanction_check: "online" },
    { name: "Yukon", status_check: "written", sanction_check: "written" },
    { name: "Nunavut", status_check: "written", sanction_check: "written" },
  ],
  "LT" => [{ status_check: "written" }],
  "CY" => [{ status_check: "written" }],
  "RO" => [{ status_check: "written", sanction_check: "written" }],
  "NO" => [{ status_check: "written" }],
  "SK" => [{ status_check: "written" }],
  "SE" => [{ status_check: "written", sanction_check: "written" }],
  "PT" => [{ status_check: "written", sanction_check: "written" }],
  "DK" => [{ status_check: "written" }],
  "FI" => [{ status_check: "written" }],
  "GH" => [
    {
      requires_preliminary_check: true,
      status_check: "online",
      sanction_check: "online",
    },
  ],
  "HK" => [{ status_check: "written", sanction_check: "written" }],
  "IN" => [],
  "JM" => [{ status_check: "written", sanction_check: "written" }],
  "NG" => [
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
  "SG" => [{ status_check: "online" }],
  "ZA" => [{ status_check: "written", sanction_check: "written" }],
  "UA" => [{ reduced_evidence_accepted: true }],
  "ZW" => [{ status_check: "written" }],
  "GG" => [],
  "JE" => [],
}.freeze

DEFAULT_COUNTRY = { eligibility_enabled: true }.freeze

DEFAULT_REGION = { name: "" }.freeze

COUNTRIES.each do |code, value|
  regions = value.is_a?(Hash) ? value[:regions] : value
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

subject_limited_countries = %w[GH IN JM NG SG ZA ZW]

subject_limited_countries.each do |country_code|
  country = Country.find_by(code: country_code)
  next unless country

  country.update!(subject_limited: true)
end
