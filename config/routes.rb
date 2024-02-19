# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  scope via: :all do
    get "/403", to: "errors#forbidden"
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  namespace :assessor_interface, path: "/assessor" do
    root to: redirect("/assessor/applications")

    resources :application_forms,
              path: "/applications",
              except: :new,
              param: :reference do
      collection do
        post "filters/apply", to: "application_forms#apply_filters"
        get "filters/clear", to: "application_forms#clear_filters"
      end

      member do
        get "status"
        get "timeline"
        get "withdraw"
      end

      get "assign-assessor", to: "assessor_assignments#new"
      post "assign-assessor", to: "assessor_assignments#create"
      get "assign-reviewer", to: "reviewer_assignments#new"
      post "assign-reviewer", to: "reviewer_assignments#create"

      resources :notes, only: %i[new create]

      resources :work_histories, path: "/work-histories", only: %i[edit update]

      resources :assessments, only: %i[edit update destroy] do
        member do
          get "review"
          get "rollback"
        end

        resources :assessment_sections, path: "/sections", only: %i[show update]

        resource :assessment_recommendation_award,
                 controller: "assessment_recommendation_award",
                 path: "/recommendation/award",
                 only: %i[show edit update] do
          get "age-range-subjects",
              to: "assessment_recommendation_award#age_range_subjects"
          get "age-range-subjects/edit",
              to: "assessment_recommendation_award#edit_age_range_subjects"
          post "age-range-subjects/edit",
               to: "assessment_recommendation_award#update_age_range_subjects"
          get "preview"
          get "confirm", to: "assessment_recommendation_award#edit_confirm"
          post "confirm", to: "assessment_recommendation_award#update_confirm"
        end

        resource :assessment_recommendation_decline,
                 controller: "assessment_recommendation_decline",
                 path: "/recommendation/decline",
                 only: %i[show edit update] do
          get "preview"
          get "confirm", to: "assessment_recommendation_decline#edit_confirm"
          post "confirm", to: "assessment_recommendation_decline#update_confirm"
        end

        resource :assessment_recommendation_review,
                 controller: "assessment_recommendation_review",
                 path: "/recommendation/review",
                 only: %i[show edit update]

        resource :assessment_recommendation_verify,
                 controller: "assessment_recommendation_verify",
                 path: "/recommendation/verify",
                 only: %i[show edit update] do
          get "verify-qualifications",
              to: "assessment_recommendation_verify#edit_verify_qualifications"
          post "verify-qualifications",
               to:
                 "assessment_recommendation_verify#update_verify_qualifications"
          get "qualification-requests",
              to: "assessment_recommendation_verify#edit_qualification_requests"
          post "qualification-requests",
               to:
                 "assessment_recommendation_verify#update_qualification_requests"
          get "reference-requests",
              to: "assessment_recommendation_verify#edit_reference_requests"
          post "reference-requests",
               to: "assessment_recommendation_verify#update_reference_requests"
          get "professional-standing",
              to: "assessment_recommendation_verify#edit_professional_standing"
          post "professional-standing",
               to:
                 "assessment_recommendation_verify#update_professional_standing"
        end

        resources :consent_requests, path: "/consent-requests", only: [] do
          member do
            get "review", to: "consent_requests#edit_review"
            post "review", to: "consent_requests#update_review"
          end
        end

        resources :further_information_requests,
                  path: "/further-information-requests",
                  only: %i[new create edit update] do
          get "preview",
              to: "further_information_requests#preview",
              on: :collection
        end

        resource :professional_standing_request,
                 path: "/professional-standing-request",
                 only: %i[show] do
          member do
            get "locate", to: "professional_standing_requests#edit_locate"
            post "locate", to: "professional_standing_requests#update_locate"
            get "request", to: "professional_standing_requests#edit_request"
            post "request", to: "professional_standing_requests#update_request"
            get "review", to: "professional_standing_requests#edit_review"
            post "review", to: "professional_standing_requests#update_review"
            get "verify", to: "professional_standing_requests#edit_verify"
            post "verify", to: "professional_standing_requests#update_verify"
            get "verify-failed",
                to: "professional_standing_requests#edit_verify_failed"
            post "verify-failed",
                 to: "professional_standing_requests#update_verify_failed"
          end
        end

        resources :qualification_requests,
                  path: "/qualification-requests",
                  only: %i[index edit update] do
          collection do
            get "consent-letter", to: "qualification_requests#consent_letter"
            get "consent-methods",
                to: "qualification_requests#index_consent_methods"
          end

          member do
            get "consent-method",
                to: "qualification_requests#edit_consent_method"
            post "consent-method",
                 to: "qualification_requests#update_consent_method"

            get "review", to: "qualification_requests#edit_review"
            post "review", to: "qualification_requests#update_review"
          end
        end

        resources :reference_requests,
                  path: "/reference-requests",
                  only: %i[index] do
          member do
            get "review", to: "reference_requests#edit_review"
            post "review", to: "reference_requests#update_review"
            get "verify", to: "reference_requests#edit_verify"
            post "verify", to: "reference_requests#update_verify"
            get "verify-failed", to: "reference_requests#edit_verify_failed"
            post "verify-failed", to: "reference_requests#update_verify_failed"
          end
        end
      end
    end

    get "/application/documents/:id/:scope/pdf",
        to: "documents#show_pdf",
        as: :application_form_document_pdf

    get "/application/documents/:document_id/uploads/:id",
        to: "uploads#show",
        as: :application_form_document_upload
  end

  namespace :eligibility_interface, path: "/eligibility" do
    root to: "start#root"

    resource :start, controller: "start", only: %i[show create]
    resource :result, controller: "result", only: %i[show]

    get "countries", to: "countries#new"
    post "countries", to: "countries#create"
    get "degree", to: "degrees#new"
    post "degree", to: "degrees#create"
    get "misconduct", to: "misconduct#new"
    post "misconduct", to: "misconduct#create"
    get "qualifications", to: "qualifications#new"
    post "qualifications", to: "qualifications#create"
    get "region", to: "region#new"
    post "region", to: "region#create"
    get "teach-children", to: "teach_children#new"
    post "teach-children", to: "teach_children#create"
    get "qualified-for-subject", to: "qualified_for_subject#new"
    post "qualified-for-subject", to: "qualified_for_subject#create"
    get "work-experience", to: "work_experience#new"
    post "work-experience", to: "work_experience#create"
  end

  namespace :support_interface, path: "/support" do
    root to: redirect("/support/features")

    mount FeatureFlags::Engine, at: "features"

    resources :countries, only: %i[index edit update] do
      get "preview", on: :member
    end

    resources :english_language_providers, only: %i[index edit update]

    resources :regions, only: %i[edit update] do
      get "preview", on: :member
    end

    resources :staff, only: %i[index edit update]

    devise_scope :staff do
      authenticate :staff do
        constraints(
          lambda do |request|
            request.env["warden"].user.support_console_permission?
          end,
        ) { mount Sidekiq::Web, at: "sidekiq" }
      end
    end
  end

  devise_for :staff,
             controllers: {
               confirmations: "staff/confirmations",
               invitations: "staff/invitations",
               passwords: "staff/passwords",
               sessions: "staff/sessions",
               unlocks: "staff/unlocks",
               omniauth_callbacks: "staff/omniauth_callbacks",
             }

  devise_scope :staff do
    get "/staff/signed_out",
        to: "staff/sessions#signed_out",
        as: "staff_signed_out"
  end

  namespace :teacher_interface, path: "/teacher" do
    root to: redirect("/teacher/application")

    resource :application_form, path: "/application", except: %i[destroy] do
      resource :personal_information,
               controller: :personal_information,
               only: %i[show] do
        member do
          get "name_and_date_of_birth",
              to: "personal_information#name_and_date_of_birth"
          post "name_and_date_of_birth",
               to: "personal_information#update_name_and_date_of_birth"
          get "alternative_name", to: "personal_information#alternative_name"
          post "alternative_name",
               to: "personal_information#update_alternative_name"
          get "check", to: "personal_information#check"
        end
      end

      resources :qualifications, except: %i[show] do
        collection do
          get "check", to: "qualifications#check_collection"

          get "add-another", to: "qualifications#add_another"
          post "add-another", to: "qualifications#submit_add_another"

          get "part-of-degree", to: "qualifications#edit_part_of_degree"
          post "part-of-degree", to: "qualifications#update_part_of_degree"
        end

        member do
          get "delete"
          get "check", to: "qualifications#check_member"
        end
      end

      resource :english_language,
               controller: :english_language,
               path: "/english-language",
               only: %i[show] do
        member do
          constraints exemption_field: /citizenship|qualification/ do
            get "exemption/:exemption_field",
                to: "english_language#edit_exemption",
                as: "exemption"
            post "exemption/:exemption_field",
                 to: "english_language#update_exemption"
          end

          get "proof-method", to: "english_language#edit_proof_method"
          post "proof-method", to: "english_language#update_proof_method"

          get "provider", to: "english_language#edit_provider"
          post "provider", to: "english_language#update_provider"

          get "provider-reference",
              to: "english_language#edit_provider_reference"
          post "provider-reference",
               to: "english_language#update_provider_reference"

          get "check", to: "english_language#check"
        end
      end

      member do
        get "age_range", to: "age_range#edit"
        post "age_range", to: "age_range#update"

        get "subjects", to: "subjects#edit"
        post "subjects", to: "subjects#update"

        get "registration_number", to: "registration_number#edit"
        post "registration_number", to: "registration_number#update"
      end

      resources :work_histories, except: %i[show edit update] do
        collection do
          get "check", to: "work_histories#check_collection"

          get "add-another"
          post "add-another", to: "work_histories#submit_add_another"

          get "requirements_unmet", to: "work_histories#requirements_unmet"
        end

        member do
          get "school", to: "work_histories#edit_school"
          post "school", to: "work_histories#update_school"

          get "contact", to: "work_histories#edit_contact"
          post "contact", to: "work_histories#update_contact"

          get "check", to: "work_histories#check_member"
          get "delete"
        end
      end

      resource :written_statement, only: %i[edit update]

      resources :documents, only: %i[show edit update] do
        resources :uploads, only: %i[show new create destroy] do
          get "delete", on: :member
        end
      end

      resources :further_information_requests, only: %i[show edit update] do
        resources :further_information_request_items,
                  path: "/items",
                  only: %i[edit update]
      end

      resources :consent_requests, path: "/consent-requests", only: %i[index] do
        member do
          get "download", to: "consent_requests#edit_download"
          post "download", to: "consent_requests#update_download"
        end

        collection do
          get "check"
          post "submit"
        end
      end
    end

    resources :reference_requests,
              path: "/references",
              param: :slug,
              only: %i[show edit update] do
      member do
        get "contact", to: "reference_requests#edit_contact"
        post "contact", to: "reference_requests#update_contact"

        get "dates", to: "reference_requests#edit_dates"
        post "dates", to: "reference_requests#update_dates"

        get "hours", to: "reference_requests#edit_hours"
        post "hours", to: "reference_requests#update_hours"

        get "children", to: "reference_requests#edit_children"
        post "children", to: "reference_requests#update_children"

        get "lessons", to: "reference_requests#edit_lessons"
        post "lessons", to: "reference_requests#update_lessons"

        get "reports", to: "reference_requests#edit_reports"
        post "reports", to: "reference_requests#update_reports"

        get "misconduct", to: "reference_requests#edit_misconduct"
        post "misconduct", to: "reference_requests#update_misconduct"

        get "satisfied", to: "reference_requests#edit_satisfied"
        post "satisfied", to: "reference_requests#update_satisfied"

        get "additional-information",
            to: "reference_requests#edit_additional_information"
        post "additional-information",
             to: "reference_requests#update_additional_information"
      end
    end
  end

  devise_for :teachers,
             path: "/teacher",
             controllers: {
               magic_links: "teachers/magic_links",
               registrations: "teachers/registrations",
               sessions: "teachers/sessions",
             }

  devise_scope :teacher do
    get "/teacher/sign_in_or_sign_up",
        to: "teachers/sessions#new_or_create",
        as: "create_or_new_teacher_session"
    post "/teacher/magic_link", to: "teachers/magic_links#create"

    get "/teacher/check_email",
        to: "teachers/sessions#check_email",
        as: "teacher_check_email"
    get "/teacher/signed_out",
        to: "teachers/sessions#signed_out",
        as: "teacher_signed_out"
  end

  resource :history, only: %i[] do
    get "back", to: "history#back", on: :collection
  end

  resources :personas, only: %i[index] do
    member do
      post "eligible", to: "personas#eligible_sign_in", as: "eligible_sign_in"
      post "staff", to: "personas#staff_sign_in", as: "staff_sign_in"
      post "teacher", to: "personas#teacher_sign_in", as: "teacher_sign_in"
    end

    collection do
      post "ineligible",
           to: "personas#ineligible_sign_in",
           as: "ineligible_sign_in"
    end
  end

  resources :autocomplete_locations, only: %i[index]

  get "accessibility", to: "static#accessibility"
  get "cookies", to: "static#cookies"
  get "privacy", to: "static#privacy"
  get "english_language_guidance", to: "static#english_language_guidance"

  root to: redirect("/eligibility")
end
