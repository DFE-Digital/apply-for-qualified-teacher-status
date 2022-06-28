require "sidekiq/web"

Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  namespace :assessor_interface, path: "/assessor" do
  end

  namespace :eligibility_interface, path: "/eligibility" do
    root to: "pages#root"
    get "degree", to: "degrees#new"
    post "degree", to: "degrees#create"
    get "countries", to: "countries#new"
    post "countries", to: "countries#create"
    get "region", to: "region#new"
    post "region", to: "region#create"
    get "qualifications", to: "qualifications#new"
    post "qualifications", to: "qualifications#create"
    get "teach-children", to: "teach_children#new"
    post "teach-children", to: "teach_children#create"
    get "start", to: "pages#start"
    get "eligible", to: "pages#eligible"
    get "ineligible", to: "pages#ineligible"
    get "misconduct", to: "misconduct#new"
    post "misconduct", to: "misconduct#create"
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

    resources :countries, only: %i[index]
    resources :regions, only: %i[edit update]

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
               unlocks: "staff/unlocks"
             }

  namespace :teacher_interface, path: "/teacher" do
  end

  resources :autocomplete_locations, only: %i[index]

  get "accessibility", to: "static#accessibility"
  get "cookies", to: "static#cookies"
  get "privacy", to: "static#privacy"

  get "performance", to: "performance#index"

  root to: redirect("/eligibility")
end
