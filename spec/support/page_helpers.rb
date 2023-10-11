module PageHelpers
  def then_i_see_the(page, **args)
    expect(send(page.to_sym)).to be_displayed(**args)
  end

  def when_i_visit_the(page, **args)
    send(page.to_sym).load(**args)
  end

  def age_range_subjects_assessment_recommendation_award_page
    @age_range_subjects_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::AgeRangeSubjectsAssessmentRecommendationAward.new
  end

  def assessor_application_page
    @assessor_application_page ||=
      PageObjects::AssessorInterface::Application.new
  end

  def assessor_applications_page
    @assessor_applications_page ||= PageObjects::AssessorInterface::Applications.new
  end

  def assessor_application_status_page
    @assessor_application_status_page ||=
      PageObjects::AssessorInterface::ApplicationStatus.new
  end

  def assessor_assessment_recommendation_review_page
    @assessor_assessment_recommendation_review_page ||=
      PageObjects::AssessorInterface::AssessmentRecommendationReview.new
  end

  def assessor_assign_assessor_page
    @assessor_assign_assessor_page ||= PageObjects::AssessorInterface::AssignAssessor.new
  end

  def assessor_assessment_section_page
    @assessor_assessment_section_page ||=
      PageObjects::AssessorInterface::AssessmentSection.new
  end
  
  def assessor_assign_reviewer_page
    @assessor_assign_reviewer_page ||= PageObjects::AssessorInterface::AssignReviewer.new
  end

  def assessor_check_personal_information_page
    @assessor_check_personal_information_page ||=
      PageObjects::AssessorInterface::CheckPersonalInformation.new
  end

  def assessor_edit_application_page
    @assessor_edit_application_page ||=
      PageObjects::AssessorInterface::EditApplication.new
  end

  def assessor_edit_qualification_request_page
    @assessor_edit_qualification_request_page ||=
      PageObjects::AssessorInterface::EditQualificationRequest.new
  end

  def assessor_edit_reference_request_page
    @assessor_edit_reference_request_page ||=
      PageObjects::AssessorInterface::EditReferenceRequest.new
  end

  def assessor_edit_work_history_page
    @assessor_edit_work_history_page ||=
      PageObjects::AssessorInterface::EditWorkHistory.new
  end

  def assessor_locate_professional_standing_request_page
    @assessor_locate_professional_standing_request_page ||=
      PageObjects::AssessorInterface::LocateProfessionalStandingRequest.new
  end

  def assessor_qualification_requests_page
    @assessor_qualification_requests_page ||=
      PageObjects::AssessorInterface::QualificationRequests.new
  end

  def assessor_reference_requests_page
    @assessor_reference_requests_page ||=
      PageObjects::AssessorInterface::ReferenceRequests.new
  end

  def assessor_reverse_decision_page
    @assessor_reverse_decision_page ||=
      PageObjects::AssessorInterface::ReverseDecision.new
  end

  def assessor_review_professional_standing_request_page
    @assessor_review_professional_standing_request_page ||=
      PageObjects::AssessorInterface::ReviewProfessionalStandingRequest.new
  end

  def assessor_review_verifications_page
    @assessor_review_verifications_page ||=
      PageObjects::AssessorInterface::ReviewVerifications.new
  end

  def assessor_timeline_page
    @assessor_timeline_page ||= PageObjects::AssessorInterface::Timeline.new
  end

  def assessor_verify_professional_standing_request_page
    @assessor_verify_professional_standing_request_page ||=
      PageObjects::AssessorInterface::VerifyProfessionalStandingRequest.new
  end

  def assessor_withdraw_application_page
    @assessor_withdraw_application_page ||=
      PageObjects::AssessorInterface::WithdrawApplication.new
  end

  def check_professional_standing_page
    @check_professional_standing_page ||=
      PageObjects::AssessorInterface::CheckProfessionalStanding.new
  end

  def check_qualifications_page
    @check_qualifications_page ||=
      PageObjects::AssessorInterface::CheckQualifications.new
  end

  def check_english_language_proficiency_page
    @check_english_language_proficiency_page ||=
      PageObjects::AssessorInterface::CheckEnglishLanguageProficiency.new
  end

  def check_work_history_page
    @check_work_history_page ||=
      PageObjects::AssessorInterface::CheckWorkHistory.new
  end

  def complete_assessment_page
    @complete_assessment_page ||=
      PageObjects::AssessorInterface::CompleteAssessment.new
  end

  def confirm_assessment_recommendation_page
    @confirm_assessment_recommendation_page ||=
      PageObjects::AssessorInterface::ConfirmAssessmentRecommendation.new
  end

  def contact_professional_standing_assessment_recommendation_verify_page
    @contact_professional_standing_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::ContactProfessionalStandingAssessmentRecommendationVerify.new
  end

  def declare_assessment_recommendation_page
    @declare_assessment_recommendation_page ||=
      PageObjects::AssessorInterface::DeclareAssessmentRecommendation.new
  end

  def country_page
    @country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def create_note_page
    @create_note_page ||= PageObjects::AssessorInterface::CreateNote.new
  end

  def degree_page
    @degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def edit_age_range_subjects_assessment_recommendation_award_page
    @edit_age_range_subjects_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::EditAgeRangeSubjectsAssessmentRecommendationAward.new
  end

  def eligible_page
    @eligible_page = PageObjects::EligibilityInterface::Eligible.new
  end

  def email_consent_letters_requests_assessment_recommendation_verify_page
    @email_consent_letters_requests_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::EmailConsentLettersAssessmentRecommendationVerify.new
  end

  def further_information_requested_page
    @further_information_requested_page =
      PageObjects::TeacherInterface::FurtherInformationRequested.new
  end

  def further_information_requested_start_page
    @further_information_requested_start_page =
      PageObjects::TeacherInterface::FurtherInformationRequestedStart.new
  end

  def further_information_required_page
    @further_information_required_page =
      PageObjects::TeacherInterface::FurtherInformationRequired.new
  end

  def ineligible_page
    @ineligible_page = PageObjects::EligibilityInterface::Ineligible.new
  end

  def login_page
    @login_page ||= PageObjects::AssessorInterface::Login.new
  end

  def misconduct_page
    @misconduct_page ||= PageObjects::EligibilityInterface::Misconduct.new
  end

  def performance_page
    @performance_page ||= PageObjects::Performance.new
  end

  def personas_page
    @personas_page ||= PageObjects::Personas.new
  end

  def preview_assessment_recommendation_page
    @preview_assessment_recommendation_page ||=
      PageObjects::AssessorInterface::PreviewAssessmentRecommendation.new
  end

  def preview_referee_assessment_recommendation_award_page
    @preview_referee_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::PreviewRefereeAssessmentRecommendationAward.new
  end

  def preview_teacher_assessment_recommendation_award_page
    @preview_teacher_assessment_recommendation_award_page ||=
      PageObjects::AssessorInterface::PreviewTeacherAssessmentRecommendationAward.new
  end

  def qualification_page
    @qualification_page ||= PageObjects::EligibilityInterface::Qualification.new
  end

  def qualification_requests_assessment_recommendation_verify_page
    @qualification_requests_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::QualificationRequestsAssessmentRecommendationVerify.new
  end

  def reference_requests_assessment_recommendation_verify_page
    @reference_requests_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::ReferenceRequestsAssessmentRecommendationVerify.new
  end

  def region_page
    @region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def review_further_information_request_page
    @review_further_information_request_page ||=
      PageObjects::AssessorInterface::ReviewFurtherInformationRequest.new
  end

  def staff_signed_out_page
    @staff_signed_out_page ||= PageObjects::Staff::SignedOut.new
  end

  def start_page
    @start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def teach_children_page
    @teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def qualified_for_subject_page
    @qualified_for_subject_page ||=
      PageObjects::EligibilityInterface::QualifiedForSubject.new
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

  def teacher_check_work_history_page
    @teacher_check_work_history_page ||=
      PageObjects::TeacherInterface::CheckWorkHistory.new
  end

  def teacher_check_work_histories_page
    @teacher_check_work_histories_page ||=
      PageObjects::TeacherInterface::CheckWorkHistories.new
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

  def teacher_magic_link_page
    @teacher_magic_link_page = PageObjects::TeacherInterface::MagicLink.new
  end

  def teacher_name_and_date_of_birth_page
    @teacher_name_and_date_of_birth_page =
      PageObjects::TeacherInterface::NameAndDateOfBirth.new
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

  def teacher_part_of_university_degree_page
    @teacher_part_of_university_degree_page ||=
      PageObjects::TeacherInterface::PartOfUniversityDegree.new
  end

  def teacher_reference_received_page
    @teacher_reference_received_page ||=
      PageObjects::TeacherInterface::ReferenceReceived.new
  end

  def teacher_reference_requested_page
    @teacher_reference_requested_page ||=
      PageObjects::TeacherInterface::ReferenceRequested.new
  end

  def teacher_registration_number_page
    @teacher_registration_number_page =
      PageObjects::TeacherInterface::RegistrationNumber.new
  end

  def teacher_signed_out_page
    @teacher_signed_out_page = PageObjects::TeacherInterface::SignedOut.new
  end

  def teacher_subjects_page
    @teacher_subjects_page = PageObjects::TeacherInterface::Subjects.new
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

  def teacher_upload_document_page
    @teacher_upload_document_page =
      PageObjects::TeacherInterface::UploadDocument.new
  end

  def check_uploaded_files_page
    @check_uploaded_files_page =
      PageObjects::TeacherInterface::CheckUploadedFiles.new
  end

  def written_statement_page
    @written_statement_page =
      PageObjects::TeacherInterface::WrittenStatement.new
  end

  def personal_information_summary_page
    @personal_information_summary_page =
      PageObjects::TeacherInterface::PersonalInformationSummary.new
  end

  def qualifications_form_page
    @qualifications_form_page =
      PageObjects::TeacherInterface::QualificationForm.new
  end

  def check_your_answers_page
    @check_your_answers_page =
      PageObjects::TeacherInterface::CheckYourAnswers.new
  end

  def submitted_application_page
    @submitted_application_page =
      PageObjects::TeacherInterface::SubmittedApplication.new
  end

  def check_your_uploads_page
    @check_your_uploads_page =
      PageObjects::TeacherInterface::CheckYourUploads.new
  end

  def request_further_information_page
    @request_further_information_form =
      PageObjects::AssessorInterface::RequestFurtherInformation.new
  end

  def further_information_request_page
    @further_information_request_page ||=
      PageObjects::AssessorInterface::FurtherInformationRequest.new
  end

  def further_information_request_preview_page
    @further_information_request_preview_page ||=
      PageObjects::AssessorInterface::FurtherInformationRequestPreview.new
  end

  def support_edit_english_language_provider_page
    @support_edit_english_language_provider_page ||=
      PageObjects::SupportInterface::EditEnglishLanguageProvider.new
  end

  def support_english_language_providers_index_page
    @support_english_language_providers_index_page ||=
      PageObjects::SupportInterface::EnglishLanguageProvidersIndex.new
  end

  def verify_age_range_subjects_page
    @verify_age_range_subjects_page ||=
      PageObjects::AssessorInterface::VerifyAgeRangeSubjectsPage.new
  end

  def verify_professional_standing_assessment_recommendation_verify_page
    @verify_professional_standing_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::VerifyProfessionalStandingAssessmentRecommendationVerify.new
  end

  def work_experience_page
    @work_experience_page ||=
      PageObjects::EligibilityInterface::WorkExperience.new
  end

  def verify_qualifications_assessment_recommendation_verify_page
    @verify_qualifications_assessment_recommendation_verify_page ||=
      PageObjects::AssessorInterface::VerifyQualificationsAssessmentRecommendationVerify.new
  end
end
