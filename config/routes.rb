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

    resources :application_forms, path: "/applications", only: %i[index show] do
      collection do
        post "filters/apply", to: "application_forms#apply_filters"
        get "filters/clear", to: "application_forms#clear_filters"
      end

      get "status", to: "application_forms#status", on: :member

      get "assign-assessor", to: "assessor_assignments#new"
      post "assign-assessor", to: "assessor_assignments#create"
      get "assign-reviewer", to: "reviewer_assignments#new"
      post "assign-reviewer", to: "reviewer_assignments#create"

      resources :notes, only: %i[new create]
      resources :timeline_events, only: :index

      resources :assessments, only: %i[edit update] do
        member do
          post "declare", to: "assessments#declare"
          post "preview", to: "assessments#preview"
          post "confirm", to: "assessments#confirm"
        end

        resources :assessment_sections,
                  path: "/sections",
                  param: :key,
                  only: %i[show update]
        resources :further_information_requests,
                  path: "/further-information-requests",
                  only: %i[new create show edit update] do
          get "preview",
              to: "further_information_requests#preview",
              on: :collection
        end
      end
    end
  end

  namespace :eligibility_interface, path: "/eligibility" do
    root to: "start#root"

    resource :start, controller: "start", only: %i[show create]
    get "eligible", to: "finish#eligible"
    get "ineligible", to: "finish#ineligible"

    get "completed-requirements", to: "completed_requirements#new"
    post "completed-requirements", to: "completed_requirements#create"
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
    get "work-experience", to: "work_experience#new"
    post "work-experience", to: "work_experience#create"
  end

  namespace :support_interface, path: "/support" do
    root to: redirect("/support/features")

    mount FeatureFlags::Engine, at: "features"

    resources :countries, only: %i[index edit update] do
      post "confirm_edit", on: :member
    end

    resources :english_language_providers, only: %i[index edit update]

    resources :regions, only: %i[edit update] do
      get "preview", on: :member
    end

    resources :staff, only: %i[index]

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
             }

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

          get "add_another", to: "qualifications#add_another"
          post "add_another", to: "qualifications#submit_add_another"
        end

        member do
          get "delete"

          get "check", to: "qualifications#check_member"

          get "part_of_university_degree",
              to: "qualifications#edit_part_of_university_degree"
          post "part_of_university_degree",
               to: "qualifications#update_part_of_university_degree"
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

      resources :work_histories, except: %i[show] do
        collection do
          get "check", to: "work_histories#check_collection"

          get "add_another", to: "work_histories#add_another"
          post "add_another", to: "work_histories#submit_add_another"

          get "has_work_history", to: "work_histories#edit_has_work_history"
          post "has_work_history", to: "work_histories#update_has_work_history"
        end

        member do
          get "check", to: "work_histories#check_member"
          get "delete"
        end
      end

      namespace :new_regs do
        resources :work_histories, except: %i[show edit update] do
          collection do
            get "check", to: "work_histories#check_collection"

            get "add_another"
            post "add_another", to: "work_histories#submit_add_another"

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
      end

      resources :documents, only: %i[show edit update] do
        resources :uploads, only: %i[new create destroy] do
          get "delete", on: :member
        end
      end

      resources :further_information_requests, only: %i[show edit update] do
        resources :further_information_request_items,
                  path: "/items",
                  only: %i[edit update]
      end
    end

    resources :reference_requests,
              path: "/references",
              param: :slug,
              only: %i[show edit]
  end

  devise_for :teachers,
             path: "/teacher",
             controllers: {
               registrations: "teachers/registrations",
               sessions: "teachers/sessions",
             }

  devise_scope :teacher do
    get "/teacher/sign_in",
        to: "teachers/sessions#new",
        as: "new_teacher_session"
    post "/teacher/sign_in",
         to: "teachers/sessions#create",
         as: "teacher_session"
    get "/teacher/sign_in_or_sign_up",
        to: "teachers/sessions#new_or_create",
        as: "create_or_new_teacher_session"

    get "/teacher/otp/new", to: "teachers/otp#new", as: "new_teacher_otp"
    post "/teacher/otp", to: "teachers/otp#create", as: "teacher_otp"
    get "/teacher/otp/retry/:error",
        to: "teachers/otp#retry",
        as: "retry_teacher_otp",
        constraints: {
          error: /(expired)|(exhausted)/,
        }

    get "/teacher/sign_out",
        to: "teachers/sessions#destroy",
        as: "destroy_teacher_session"
    get "/teacher/signed_out",
        to: "teachers/sessions#signed_out",
        as: "teacher_signed_out"
  end

  resource :history, only: %i[] do
    get "back", to: "history#back", on: :collection
  end

  resources :personas, only: %i[index] do
    member do
      post "staff", to: "personas#staff_sign_in", as: "staff_sign_in"
      post "teacher", to: "personas#teacher_sign_in", as: "teacher_sign_in"
    end
  end

  resources :autocomplete_locations, only: %i[index]

  get "accessibility", to: "static#accessibility"
  get "cookies", to: "static#cookies"
  get "privacy", to: "static#privacy"

  get "performance", to: "performance#index"

  root to: redirect("/eligibility")
end
