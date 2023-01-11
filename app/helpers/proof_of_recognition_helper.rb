module ProofOfRecognitionHelper
  def proof_of_recognition_requirements_for(region:)
    if region.status_check_written? && region.sanction_check_written?
      return(
        written_status_reasons.insert(2, *written_sanction_reasons(region)) +
          ["that you’re qualified to teach at state or government schools"]
      )
    end

    return written_status_reasons if region.status_check_written?
    return written_sanction_reasons(region) if region.sanction_check_written?
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

  private

  def written_status_reasons
    [
      "that you've completed a teaching qualification/teacher training",
      "that you’ve successfully completed any period of professional experience " \
        "comparable to an induction period (if required)",
      "the age ranges and subjects you’re qualified to teach",
    ]
  end

  def written_sanction_reasons(region)
    if region.country.teaching_authority_checks_sanctions?
      [
        "that your authorisation to teach has never been suspended, barred, " \
          "cancelled, revoked or restricted, and that you have no sanctions against you",
      ]
    elsif region.application_form_skip_work_history?
      [
        "if you have completed your induction in #{CountryName.from_region(region, with_definite_article: true)}",
      ]
    else
      []
    end
  end
end
