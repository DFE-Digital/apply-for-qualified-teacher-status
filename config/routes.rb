require "sidekiq/web"

Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  namespace :assessor_interface, path: "/assessor" do
    root to: redirect("/assessor/applications")

    resources :application_forms, path: "/applications", only: %i[index show] do
      get "assign-assessor", to: "assessor_assignments#new"
      post "assign-assessor", to: "assessor_assignments#create"
      get "assign-reviewer", to: "reviewer_assignments#new"
      post "assign-reviewer", to: "reviewer_assignments#create"

      resources :notes, only: %i[new create]
      resources :timeline_events, only: :index

      resources :assessments, only: %i[edit update] do
        resources :assessment_sections,
                  path: "/sections",
                  param: :key,
                  only: %i[show update]
        resources :further_information_requests,
                  path: "/further-information-requests",
                  only: %i[new create show]
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
  end

  namespace :support_interface, path: "/support" do
    root to: redirect("/support/features")

    get "/features", to: "feature_flags#index"
    post "/features/:feature_name/activate",
         to: "feature_flags#activate",
         as: :activate_feature
    post "/features/:feature_name/deactivate",
         to: "feature_flags#deactivate",
         as: :deactivate_feature

    resources :countries, only: %i[index edit update] do
      post "confirm_edit", on: :member
    end

    resources :regions, only: %i[edit update] do
      get "preview", on: :member
    end

    resources :staff, only: %i[index]

    devise_scope :staff do
      authenticate :staff do
        mount Sidekiq::Web, at: "sidekiq"
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
          get "check", to: "qualifications#check"

          get "add_another", to: "qualifications#add_another"
          post "add_another", to: "qualifications#submit_add_another"
        end

        member do
          get "delete"

          get "part_of_university_degree",
              to: "qualifications#edit_part_of_university_degree"
          post "part_of_university_degree",
               to: "qualifications#update_part_of_university_degree"
        end
      end

      member do
        get "age_range", to: "age_range#edit"
        post "age_range", to: "age_range#update"

        get "subjects", to: "subjects#edit"
        post "subjects", to: "subjects#update"
        get "subjects/delete", to: "subjects#delete"

        get "registration_number", to: "registration_number#edit"
        post "registration_number", to: "registration_number#update"
      end

      resources :work_histories, except: %i[show] do
        get "delete", on: :member

        collection do
          get "check", to: "work_histories#check"

          get "add_another", to: "work_histories#add_another"
          post "add_another", to: "work_histories#submit_add_another"

          get "has_work_history", to: "work_histories#edit_has_work_history"
          post "has_work_history", to: "work_histories#update_has_work_history"
        end
      end

      resources :documents, only: %i[edit update] do
        resources :uploads, only: %i[new create destroy] do
          get "delete", on: :member
        end
      end

      resources :further_information_requests, only: %i[show] do
        resources :further_information_request_items,
                  path: "/items",
                  only: %i[edit]
      end
    end
  end

  devise_for :teachers,
             path: "/teacher",
             controllers: {
               confirmations: "teachers/confirmations",
               registrations: "teachers/registrations",
               sessions: "teachers/sessions",
             }

  devise_scope :teacher do
    get "/teacher/create_or_sign_in",
        to: "teachers/sessions#new_or_create",
        as: "create_or_new_teacher_session"
    get "/teacher/magic_link",
        to: "teachers/magic_links#show",
        as: "teacher_magic_link"
    get "/teacher/check_email",
        to: "teachers/sessions#check_email",
        as: "teacher_check_email"
    get "/teacher/signed_out",
        to: "teachers/sessions#signed_out",
        as: "teacher_signed_out"
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
