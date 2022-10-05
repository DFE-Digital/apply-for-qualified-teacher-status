module ProofOfRecognitionHelper
  WRITTEN_STATUS_REASONS = [
    "that you've completed a teaching qualification/teacher training",
    "that you’ve successfully completed any period of professional experience " \
      "comparable to an induction period (if required)",
    "the age ranges and subjects you’re qualified to teach",
  ].freeze

  WRITTEN_SANCTION_REASONS = [
    "that your authorisation to teach has never been suspended, barred, " \
      "cancelled, revoked or restricted, and that you have no sanctions against you",
  ].freeze

  def proof_of_recognition_requirements_for(region:)
    if region.status_check_written? && region.sanction_check_written?
      return(
        WRITTEN_STATUS_REASONS + WRITTEN_SANCTION_REASONS +
          ["that you’re qualified to teach at state or government schools"]
      )
    end

    return WRITTEN_STATUS_REASONS if region.status_check_written?
    return WRITTEN_SANCTION_REASONS if region.sanction_check_written?
    []
  end

  def proof_of_recognition_description_for(region:)
    if region.status_check_written?
      return(
        "The authority or territory that recognises you as a teacher must confirm:"
      )
    end
    if region.sanction_check_written?
      "The education department or authority must also confirm in writing:"
    end
  end
end
