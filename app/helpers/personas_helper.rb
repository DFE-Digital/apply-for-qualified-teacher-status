# frozen_string_literal: true

module PersonasHelper
  def region_bucket_for_persona(persona)
    REGION_BUCKETS[persona.slice(:status_check, :sanction_check)]
  end

  def persona_check_tag(check)
    case check
    when "none"
      govuk_tag(text: "None", colour: "yellow")
    when "online"
      govuk_tag(text: "Online", colour: "orange")
    when "written"
      govuk_tag(text: "Written", colour: "pink")
    end
  end

  REGION_BUCKETS = {
    { status_check: "online", sanction_check: "online" } => 1,
    { status_check: "written", sanction_check: "written" } => 2,
    { status_check: "online", sanction_check: "written" } => 3,
    { status_check: "written", sanction_check: "none" } => 4,
    { status_check: "online", sanction_check: "none" } => 5,
    { status_check: "none", sanction_check: "none" } => 6,
  }.freeze
end
