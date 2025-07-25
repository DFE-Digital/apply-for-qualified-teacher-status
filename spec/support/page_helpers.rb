# frozen_string_literal: true

module PageHelpers
  def then_i_see_the(page, **args)
    expect(send(page.to_sym)).to be_displayed(**args)
  end

  def when_i_visit_the(page, **args)
    send(page.to_sym).load(**args)
  end

  def assessor_age_range_subjects_assessment_recommendation_award_page
    @assessor_age_range_subjects_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::AgeRangeSubjectsAssessmentRecommendationAward.new
  end

  def assessor_application_page
    @assessor_application_page ||=
      PageObjects::AssessorInterface::Application.new
  end

  def assessor_application_status_page
    @assessor_application_status_page ||=
      PageObjects::AssessorInterface::ApplicationStatus.new
  end

  def assessor_applications_page
    @assessor_applications_page ||=
      PageObjects::AssessorInterface::Applications.new
  end

  def assessor_archive_suitability_record_page
    @assessor_archive_suitability_record_page ||=
      PageObjects::AssessorInterface::ArchiveSuitabilityRecord.new
  end

  def assessor_assessment_recommendation_review_page
    @assessor_assessment_recommendation_review_page ||=
      PageObjects::AssessorInterface::AssessmentRecommendationReview.new
  end

  def assessor_assessment_recommendation_verify_page
    @assessor_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::AssessmentRecommendationVerify.new
  end

  def assessor_assessment_section_page
    @assessor_assessment_section_page ||=
      PageObjects::AssessorInterface::AssessmentSection.new
  end

  def assessor_assign_assessor_page
    @assessor_assign_assessor_page ||=
      PageObjects::AssessorInterface::AssignAssessor.new
  end

  def assessor_assign_reviewer_page
    @assessor_assign_reviewer_page ||=
      PageObjects::AssessorInterface::AssignReviewer.new
  end

  def assessor_prioritisation_work_history_checks_page
    @assessor_prioritisation_work_history_checks_page ||=
      PageObjects::AssessorInterface::PrioritisationWorkHistoryChecks.new
  end

  def assessor_prioritisation_work_history_check_page
    @assessor_prioritisation_work_history_check_page ||=
      PageObjects::AssessorInterface::PrioritisationWorkHistoryCheck.new
  end

  def new_assessor_prioritisation_references_page
    @new_assessor_prioritisation_references_page ||=
      PageObjects::AssessorInterface::PrioritisationReferencesNew.new
  end

  def assessor_prioritisation_references_page
    @assessor_prioritisation_references_page ||=
      PageObjects::AssessorInterface::PrioritisationReferences.new
  end

  def confirmation_assessor_prioritisation_references_page
    @confirmation_assessor_prioritisation_references_page ||=
      PageObjects::AssessorInterface::PrioritisationReferencesConfirmation.new
  end

  def review_assessor_prioritisation_reference_page
    @review_assessor_prioritisation_reference_page ||=
      PageObjects::AssessorInterface::PrioritisationReferenceReview.new
  end

  def assessor_prioritisation_decision_page
    @assessor_prioritisation_decision_page ||=
      PageObjects::AssessorInterface::PrioritisationDecision.new
  end

  def assessor_check_english_language_proficiency_page
    @assessor_check_english_language_proficiency_page ||=
      PageObjects::AssessorInterface::CheckEnglishLanguageProficiency.new
  end

  def assessor_check_personal_information_page
    @assessor_check_personal_information_page ||=
      PageObjects::AssessorInterface::CheckPersonalInformation.new
  end

  def assessor_check_professional_standing_page
    @assessor_check_professional_standing_page ||=
      PageObjects::AssessorInterface::CheckProfessionalStanding.new
  end

  def assessor_check_qualifications_page
    @assessor_check_qualifications_page ||=
      PageObjects::AssessorInterface::CheckQualifications.new
  end

  def assessor_edit_teaching_qualification_page
    @assessor_edit_teaching_qualification_page ||=
      PageObjects::AssessorInterface::EditTeachingQualification.new
  end

  def assessor_assign_teaching_qualification_page
    @assessor_assign_teaching_qualification_page ||=
      PageObjects::AssessorInterface::AssignTeachingQualification.new
  end

  def assessor_assign_teaching_qualification_invalid_country_page
    @assessor_assign_teaching_qualification_invalid_country_page ||=
      PageObjects::AssessorInterface::AssignTeachingQualificationInvalidCountry.new
  end

  def assessor_assign_teaching_qualification_invalid_work_duration_page
    @assessor_assign_teaching_qualification_invalid_work_duration_page ||=
      PageObjects::AssessorInterface::AssignTeachingQualificationInvalidWorkDuration.new
  end

  def assessor_check_work_history_page
    @assessor_check_work_history_page ||=
      PageObjects::AssessorInterface::CheckWorkHistory.new
  end

  def assessor_complete_assessment_page
    @assessor_complete_assessment_page ||=
      PageObjects::AssessorInterface::CompleteAssessment.new
  end

  def assessor_confirm_assessment_recommendation_page
    @assessor_confirm_assessment_recommendation_page ||=
      PageObjects::AssessorInterface::ConfirmAssessmentRecommendation.new
  end

  def assessor_consent_qualification_request_page
    @assessor_consent_qualification_request_page ||=
      PageObjects::AssessorInterface::ConsentQualificationRequest.new
  end

  def assessor_create_note_page
    @assessor_create_note_page ||=
      PageObjects::AssessorInterface::CreateNote.new
  end

  def assessor_create_suitability_record_page
    @assessor_create_suitability_record_page ||=
      PageObjects::AssessorInterface::CreateSuitabilityRecord.new
  end

  def assessor_declare_assessment_recommendation_page
    @assessor_declare_assessment_recommendation_page ||=
      PageObjects::AssessorInterface::DeclareAssessmentRecommendation.new
  end

  def assessor_edit_age_range_subjects_assessment_recommendation_award_page
    @assessor_edit_age_range_subjects_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::EditAgeRangeSubjectsAssessmentRecommendationAward.new
  end

  def assessor_edit_application_email_page
    @assessor_edit_application_email_page ||=
      PageObjects::AssessorInterface::EditApplicationEmail.new
  end

  def assessor_edit_application_name_page
    @assessor_edit_application_name_page ||=
      PageObjects::AssessorInterface::EditApplicationName.new
  end

  def assessor_edit_suitability_record_page
    @assessor_edit_suitability_record_page ||=
      PageObjects::AssessorInterface::EditSuitabilityRecord.new
  end

  def assessor_edit_work_history_page
    @assessor_edit_work_history_page ||=
      PageObjects::AssessorInterface::EditWorkHistory.new
  end

  def assessor_further_information_request_preview_page
    @assessor_further_information_request_preview_page ||=
      PageObjects::AssessorInterface::FurtherInformationRequestPreview.new
  end

  def assessor_locate_professional_standing_request_page
    @assessor_locate_professional_standing_request_page ||=
      PageObjects::AssessorInterface::LocateProfessionalStandingRequest.new
  end

  def assessor_login_page
    @assessor_login_page ||= PageObjects::AssessorInterface::Login.new
  end

  def assessor_professional_standing_assessment_recommendation_verify_page
    @assessor_professional_standing_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::ProfessionalStandingAssessmentRecommendationVerify.new
  end

  def assessor_professional_standing_request_page
    @assessor_professional_standing_request_page ||=
      PageObjects::AssessorInterface::ProfessionalStandingRequest.new
  end

  def assessor_qualification_requests_assessment_recommendation_verify_page
    @assessor_qualification_requests_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::QualificationRequestsAssessmentRecommendationVerify.new
  end

  def assessor_qualification_requests_check_consent_methods_page
    @assessor_qualification_requests_check_consent_methods_page ||=
      PageObjects::AssessorInterface::QualificationRequestsCheckConsentMethods.new
  end

  def assessor_qualification_requests_consent_methods_page
    @assessor_qualification_requests_consent_methods_page ||=
      PageObjects::AssessorInterface::QualificationRequestsConsentMethods.new
  end

  def assessor_qualification_requests_unsigned_consent_document_page
    @assessor_qualification_requests_unsigned_consent_document_page ||=
      PageObjects::AssessorInterface::QualificationRequestsUnsignedConsentDocument.new
  end

  def assessor_qualification_requests_page
    @assessor_qualification_requests_page ||=
      PageObjects::AssessorInterface::QualificationRequests.new
  end

  def assessor_reference_requests_assessment_recommendation_verify_page
    @assessor_reference_requests_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::ReferenceRequestsAssessmentRecommendationVerify.new
  end

  def assessor_reference_requests_page
    @assessor_reference_requests_page ||=
      PageObjects::AssessorInterface::ReferenceRequests.new
  end

  def assessor_request_further_information_page
    @request_further_information_form =
      PageObjects::AssessorInterface::RequestFurtherInformation.new
  end

  def assessor_request_professional_standing_request_page
    @assessor_request_professional_standing_request_page ||=
      PageObjects::AssessorInterface::RequestProfessionalStandingRequest.new
  end

  def assessor_request_qualification_request_page
    @assessor_request_qualification_request_page ||=
      PageObjects::AssessorInterface::RequestQualificationRequest.new
  end

  def assessor_reverse_decision_page
    @assessor_reverse_decision_page ||=
      PageObjects::AssessorInterface::ReverseDecision.new
  end

  def assessor_review_consent_request_page
    @assessor_review_consent_request_page ||=
      PageObjects::AssessorInterface::ReviewConsentRequest.new
  end

  def assessor_review_further_information_request_page
    @assessor_review_further_information_request_page ||=
      PageObjects::AssessorInterface::ReviewFurtherInformationRequest.new
  end

  def assessor_decline_further_information_request_page
    @assessor_decline_further_information_request_page ||=
      PageObjects::AssessorInterface::DeclineFurtherInformationRequest.new
  end

  def assessor_follow_up_further_information_request_page
    @assessor_follow_up_further_information_request_page ||=
      PageObjects::AssessorInterface::FollowUpFurtherInformationRequest.new
  end

  def assessor_confirm_follow_up_further_information_request_page
    @assessor_confirm_follow_up_further_information_request_page ||=
      PageObjects::AssessorInterface::ConfirmFollowUpFurtherInformationRequest.new
  end

  def assessor_review_professional_standing_request_page
    @assessor_review_professional_standing_request_page ||=
      PageObjects::AssessorInterface::ReviewProfessionalStandingRequest.new
  end

  def assessor_review_qualification_request_page
    @assessor_review_qualification_request_page ||=
      PageObjects::AssessorInterface::ReviewQualificationRequest.new
  end

  def assessor_review_reference_request_page
    @assessor_review_reference_request_page ||=
      PageObjects::AssessorInterface::ReviewReferenceRequest.new
  end

  def assessor_review_verifications_page
    @assessor_review_verifications_page ||=
      PageObjects::AssessorInterface::ReviewVerifications.new
  end

  def assessor_send_signed_consent_documents_page
    @assessor_send_signed_consent_documents_page ||=
      PageObjects::AssessorInterface::SendSignedConsentDocuments.new
  end

  def assessor_staff_archive_page
    @assessor_staff_archive_page ||=
      PageObjects::AssessorInterface::StaffArchive.new
  end

  def assessor_staff_unarchive_page
    @assessor_staff_unarchive_page ||=
      PageObjects::AssessorInterface::StaffUnarchive.new
  end

  def assessor_staff_index_page
    @assessor_staff_index_page ||=
      PageObjects::AssessorInterface::StaffIndex.new
  end

  def assessor_suitability_records_page
    @assessor_suitability_records_page ||=
      PageObjects::AssessorInterface::SuitabilityRecords.new
  end

  def assessor_timeline_page
    @assessor_timeline_page ||= PageObjects::AssessorInterface::Timeline.new
  end

  def assessor_upload_consent_document_page
    @assessor_upload_consent_document_page ||=
      PageObjects::AssessorInterface::UploadConsentDocument.new
  end

  def assessor_verify_age_range_subjects_page
    @assessor_verify_age_range_subjects_page ||=
      PageObjects::AssessorInterface::VerifyAgeRangeSubjectsPage.new
  end

  def assessor_verify_consent_request_page
    @assessor_verify_consent_request_page ||=
      PageObjects::AssessorInterface::VerifyConsentRequest.new
  end

  def assessor_verify_failed_consent_request_page
    @assessor_verify_failed_consent_request_page ||=
      PageObjects::AssessorInterface::VerifyFailedConsentRequest.new
  end

  def assessor_verify_failed_professional_standing_request_page
    @assessor_verify_failed_professional_standing_request_page ||=
      PageObjects::AssessorInterface::VerifyFailedProfessionalStandingRequest.new
  end

  def assessor_verify_failed_qualification_request_page
    @assessor_verify_failed_qualification_request_page ||=
      PageObjects::AssessorInterface::VerifyFailedQualificationRequest.new
  end

  def assessor_verify_failed_reference_request_page
    @assessor_verify_failed_reference_request_page ||=
      PageObjects::AssessorInterface::VerifyFailedReferenceRequest.new
  end

  def assessor_verify_professional_standing_request_page
    @assessor_verify_professional_standing_request_page ||=
      PageObjects::AssessorInterface::VerifyProfessionalStandingRequest.new
  end

  def assessor_verify_qualification_request_page
    @assessor_verify_qualification_request_page ||=
      PageObjects::AssessorInterface::VerifyQualificationRequest.new
  end

  def assessor_verify_qualifications_assessment_recommendation_verify_page
    @assessor_verify_qualifications_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::VerifyQualificationsAssessmentRecommendationVerify.new
  end

  def assessor_verify_reference_request_page
    @assessor_verify_reference_request_page ||=
      PageObjects::AssessorInterface::VerifyReferenceRequest.new
  end

  def assessor_withdraw_application_page
    @assessor_withdraw_application_page ||=
      PageObjects::AssessorInterface::WithdrawApplication.new
  end

  def eligibility_country_page
    @eligibility_country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def eligibility_degree_page
    @eligibility_degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def eligibility_eligible_page
    @eligibility_eligible_page = PageObjects::EligibilityInterface::Eligible.new
  end

  def eligibility_ineligible_page
    @eligibility_ineligible_page =
      PageObjects::EligibilityInterface::Ineligible.new
  end

  def eligibility_misconduct_page
    @eligibility_misconduct_page ||=
      PageObjects::EligibilityInterface::Misconduct.new
  end

  def eligibility_qualification_page
    @eligibility_qualification_page ||=
      PageObjects::EligibilityInterface::Qualification.new
  end

  def eligibility_qualified_for_subject_page
    @eligibility_qualified_for_subject_page ||=
      PageObjects::EligibilityInterface::QualifiedForSubject.new
  end

  def eligibility_region_page
    @eligibility_region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def eligibility_start_page
    @eligibility_start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def eligibility_teach_children_page
    @eligibility_teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def eligibility_work_experience_page
    @eligibility_work_experience_page ||=
      PageObjects::EligibilityInterface::WorkExperience.new
  end

  def eligibility_work_experience_in_england_page
    @eligibility_work_experience_in_england_page ||=
      PageObjects::EligibilityInterface::WorkExperienceInEngland.new
  end

  def personas_page
    @personas_page ||= PageObjects::Personas.new
  end

  def support_edit_english_language_provider_page
    @support_edit_english_language_provider_page ||=
      PageObjects::SupportInterface::EditEnglishLanguageProvider.new
  end

  def support_english_language_providers_index_page
    @support_english_language_providers_index_page ||=
      PageObjects::SupportInterface::EnglishLanguageProvidersIndex.new
  end

  def staff_signed_out_page
    @staff_signed_out_page ||= PageObjects::Staff::SignedOut.new
  end

  def teacher_add_another_qualification_page
    @teacher_add_another_qualification_page ||=
      PageObjects::TeacherInterface::AddAnotherQualification.new
  end

  def teacher_add_another_work_history_page
    @teacher_add_another_work_history_page ||=
      PageObjects::TeacherInterface::AddAnotherWorkHistory.new
  end

  def teacher_age_range_page
    @teacher_age_range_page = PageObjects::TeacherInterface::AgeRange.new
  end

  def teacher_alternative_name_page
    @teacher_alternative_name_page =
      PageObjects::TeacherInterface::AlternativeName.new
  end

  def teacher_application_page
    @teacher_application_page = PageObjects::TeacherInterface::Application.new
  end

  def teacher_check_consent_requests_page
    @teacher_check_consent_requests_page =
      PageObjects::TeacherInterface::CheckConsentRequests.new
  end

  def teacher_check_document_page
    @teacher_check_document_page =
      PageObjects::TeacherInterface::CheckDocument.new
  end

  def teacher_check_email_page
    @teacher_check_email_page = PageObjects::TeacherInterface::CheckEmail.new
  end

  def teacher_check_english_language_page
    @teacher_check_english_language_page ||=
      PageObjects::TeacherInterface::CheckEnglishLanguage.new
  end

  def teacher_check_further_information_request_answers_page
    @teacher_check_further_information_request_answers_page =
      PageObjects::TeacherInterface::CheckFurtherInformationRequestAnswers.new
  end

  def teacher_check_personal_information_page
    @teacher_check_personal_information_page =
      PageObjects::TeacherInterface::CheckPersonalInformation.new
  end

  def teacher_check_passport_document_page
    @teacher_check_passport_document_page =
      PageObjects::TeacherInterface::CheckPassportDocument.new
  end

  def teacher_check_qualification_page
    @teacher_check_qualification_page ||=
      PageObjects::TeacherInterface::CheckQualification.new
  end

  def teacher_check_qualifications_page
    @teacher_check_qualifications_page ||=
      PageObjects::TeacherInterface::CheckQualifications.new
  end

  def teacher_check_reference_request_answers_page
    @teacher_check_reference_request_answers_page ||=
      PageObjects::TeacherInterface::CheckReferenceRequestAnswers.new
  end

  def teacher_check_prioritisation_reference_request_answers_page
    @teacher_check_prioritisation_reference_request_answers_page ||=
      PageObjects::TeacherInterface::CheckPrioritisationReferenceRequestAnswers.new
  end

  def teacher_check_uploaded_files_page
    @teacher_check_uploaded_files_page =
      PageObjects::TeacherInterface::CheckUploadedFiles.new
  end

  def teacher_check_work_histories_page
    @teacher_check_work_histories_page ||=
      PageObjects::TeacherInterface::CheckWorkHistories.new
  end

  def teacher_check_work_history_page
    @teacher_check_work_history_page ||=
      PageObjects::TeacherInterface::CheckWorkHistory.new
  end

  def teacher_check_your_answers_page
    @teacher_check_your_answers_page =
      PageObjects::TeacherInterface::CheckYourAnswers.new
  end

  def teacher_view_answers_page
    @teacher_view_answers_page =
      PageObjects::TeacherInterface::ViewYourAnswers.new
  end

  def teacher_check_your_uploads_page
    @teacher_check_your_uploads_page =
      PageObjects::TeacherInterface::CheckYourUploads.new
  end

  def teacher_consent_requests_page
    @teacher_consent_requests_page =
      PageObjects::TeacherInterface::ConsentRequests.new
  end

  def teacher_declined_application_page
    @teacher_declined_application_page ||=
      PageObjects::TeacherInterface::DeclinedApplication.new
  end

  def teacher_delete_qualification_page
    @teacher_delete_qualification_page =
      PageObjects::TeacherInterface::DeleteQualification.new
  end

  def teacher_delete_work_history_page
    @teacher_delete_work_history_page =
      PageObjects::TeacherInterface::DeleteWorkHistory.new
  end

  def teacher_document_available_page
    @teacher_document_available_page =
      PageObjects::TeacherInterface::DocumentAvailable.new
  end

  def teacher_download_consent_request_page
    @teacher_download_consent_request_page =
      PageObjects::TeacherInterface::DownloadConsentRequest.new
  end

  def teacher_edit_qualification_page
    @teacher_edit_qualification_page ||=
      PageObjects::TeacherInterface::EditQualification.new
  end

  def teacher_edit_reference_request_additional_information_page
    @teacher_edit_reference_request_additional_information_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestAdditionalInformation.new
  end

  def teacher_edit_reference_request_children_page
    @teacher_edit_reference_request_children_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestChildren.new
  end

  def teacher_edit_reference_request_contact_page
    @teacher_edit_reference_request_contact_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestContact.new
  end

  def teacher_edit_reference_request_dates_page
    @teacher_edit_reference_request_dates_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestDates.new
  end

  def teacher_edit_reference_request_hours_page
    @teacher_edit_reference_request_hours_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestHours.new
  end

  def teacher_edit_reference_request_lessons_page
    @teacher_edit_reference_request_lessons_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestLessons.new
  end

  def teacher_edit_reference_request_misconduct_page
    @teacher_edit_reference_request_misconduct_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestMisconduct.new
  end

  def teacher_edit_reference_request_reports_page
    @teacher_edit_reference_request_reports_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestReports.new
  end

  def teacher_edit_reference_request_satisfied_page
    @teacher_edit_reference_request_satisfied_page ||=
      PageObjects::TeacherInterface::EditReferenceRequestSatisfied.new
  end

  def teacher_edit_work_history_contact_page
    @teacher_edit_work_history_contact_page ||=
      PageObjects::TeacherInterface::EditWorkHistoryContact.new
  end

  def teacher_edit_work_history_school_page
    @teacher_edit_work_history_school_page ||=
      PageObjects::TeacherInterface::EditWorkHistorySchool.new
  end

  def teacher_edit_written_statement_page
    @teacher_edit_written_statement_page ||=
      PageObjects::TeacherInterface::EditWrittenStatement.new
  end

  def teacher_english_language_exemption_page
    @teacher_english_language_exemption_page ||=
      PageObjects::TeacherInterface::EnglishLanguageExemption.new
  end

  def teacher_english_language_proof_method_page
    @teacher_english_language_proof_method_page ||=
      PageObjects::TeacherInterface::EnglishLanguageProofMethod.new
  end

  def teacher_english_language_provider_page
    @teacher_english_language_provider_page ||=
      PageObjects::TeacherInterface::EnglishLanguageProvider.new
  end

  def teacher_english_language_provider_reference_page
    @teacher_english_language_provider_reference_page ||=
      PageObjects::TeacherInterface::EnglishLanguageProviderReference.new
  end

  def teacher_further_information_requested_page
    @teacher_further_information_requested_page =
      PageObjects::TeacherInterface::FurtherInformationRequested.new
  end

  def teacher_further_information_requested_start_page
    @teacher_further_information_requested_start_page =
      PageObjects::TeacherInterface::FurtherInformationRequestedStart.new
  end

  def teacher_further_information_required_page
    @teacher_further_information_required_page =
      PageObjects::TeacherInterface::FurtherInformationRequired.new
  end

  def teacher_magic_link_page
    @teacher_magic_link_page = PageObjects::TeacherInterface::MagicLink.new
  end

  def teacher_name_and_date_of_birth_page
    @teacher_name_and_date_of_birth_page =
      PageObjects::TeacherInterface::NameAndDateOfBirth.new
  end

  def teacher_passport_expiry_date_page
    @teacher_passport_expiry_date_page =
      PageObjects::TeacherInterface::PassportExpiryDate.new
  end

  def teacher_passport_expiry_date_interruption_page
    @teacher_passport_expiry_date_page =
      PageObjects::TeacherInterface::PassportExpiryDateInterruption.new
  end

  def teacher_new_application_page
    @teacher_new_application_page =
      PageObjects::TeacherInterface::NewApplication.new
  end

  def teacher_new_qualification_page
    @teacher_new_qualification_page ||=
      PageObjects::TeacherInterface::NewQualification.new
  end

  def teacher_new_work_history_page
    @teacher_new_work_history_page ||=
      PageObjects::TeacherInterface::NewWorkHistory.new
  end

  def teacher_meets_criteria_other_england_work_history_page
    @teacher_meets_criteria_other_england_work_history_page ||=
      PageObjects::TeacherInterface::MeetsCriteriaOtherEnglandWorkHistory.new
  end

  def teacher_new_other_england_work_history_page
    @teacher_new_other_england_work_history_page ||=
      PageObjects::TeacherInterface::NewOtherEnglandWorkHistory.new
  end

  def teacher_edit_other_england_work_history_contact_page
    @teacher_edit_other_england_work_history_contact_page ||=
      PageObjects::TeacherInterface::EditOtherEnglandWorkHistoryContact.new
  end

  def teacher_check_other_england_work_history_page
    @teacher_check_other_england_work_history_page ||=
      PageObjects::TeacherInterface::CheckOtherEnglandWorkHistory.new
  end

  def teacher_check_other_england_work_histories_page
    @teacher_check_other_england_work_histories_page ||=
      PageObjects::TeacherInterface::CheckOtherEnglandWorkHistories.new
  end

  def teacher_add_another_other_england_work_history_page
    @teacher_add_another_other_england_work_history_page ||=
      PageObjects::TeacherInterface::AddAnotherOtherEnglandWorkHistory.new
  end

  def teacher_delete_other_england_work_history_page
    @teacher_delete_other_england_work_history_page =
      PageObjects::TeacherInterface::DeleteOtherEnglandWorkHistory.new
  end

  def teacher_teaching_qualification_part_of_degree_page
    @teacher_teaching_qualification_part_of_degree_page ||=
      PageObjects::TeacherInterface::TeachingQualificationPartOfDegree.new
  end

  def teacher_personal_information_summary_page
    @teacher_personal_information_summary_page =
      PageObjects::TeacherInterface::PersonalInformationSummary.new
  end

  def teacher_reference_received_page
    @teacher_reference_received_page ||=
      PageObjects::TeacherInterface::ReferenceReceived.new
  end

  def teacher_reference_requested_page
    @teacher_reference_requested_page ||=
      PageObjects::TeacherInterface::ReferenceRequested.new
  end

  def teacher_prioritisation_reference_received_page
    @teacher_prioritisation_reference_received_page ||=
      PageObjects::TeacherInterface::PrioritisationReferenceReceived.new
  end

  def teacher_prioritisation_reference_requested_page
    @teacher_prioritisation_reference_requested_page ||=
      PageObjects::TeacherInterface::PrioritisationReferenceRequested.new
  end

  def teacher_edit_prioritisation_reference_request_contact_page
    @teacher_edit_prioritisation_reference_request_contact_page ||=
      PageObjects::TeacherInterface::EditPrioritisationReferenceRequestContact.new
  end

  def teacher_edit_prioritisation_reference_request_confirm_applicant_page
    @teacher_edit_prioritisation_reference_request_confirm_applicant_page ||=
      PageObjects::TeacherInterface::EditPrioritisationReferenceRequestConfirmApplicant.new
  end

  def teacher_registration_number_page
    @teacher_registration_number_page =
      PageObjects::TeacherInterface::RegistrationNumber.new
  end

  def teacher_ghana_registration_number_page
    @teacher_registration_number_page =
      PageObjects::TeacherInterface::GhanaRegistrationNumber.new
  end

  def teacher_signed_out_page
    @teacher_signed_out_page = PageObjects::TeacherInterface::SignedOut.new
  end

  def teacher_sign_in_page
    @teacher_sign_in_page = PageObjects::TeacherInterface::SignIn.new
  end

  def teacher_sign_in_or_sign_up_page
    @teacher_sign_in_or_sign_up_page =
      PageObjects::TeacherInterface::SignInOrSignUp.new
  end

  def teacher_sign_up_page
    @teacher_sign_up_page = PageObjects::TeacherInterface::SignUp.new
  end

  def teacher_subjects_page
    @teacher_subjects_page = PageObjects::TeacherInterface::Subjects.new
  end

  def teacher_submitted_application_page
    @teacher_submitted_application_page =
      PageObjects::TeacherInterface::SubmittedApplication.new
  end

  def teacher_upload_document_page
    @teacher_upload_document_page =
      PageObjects::TeacherInterface::UploadDocument.new
  end

  def teacher_written_statement_page
    @teacher_written_statement_page =
      PageObjects::TeacherInterface::WrittenStatement.new
  end
end
