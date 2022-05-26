Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/500", to: "errors#internal_server_error"
  end

  namespace :support_interface, path: "/support" do
    get "/features", to: "feature_flags#index"
    post "/features/:feature_name/activate",
         to: "feature_flags#activate",
         as: :activate_feature
    post "/features/:feature_name/deactivate",
         to: "feature_flags#deactivate",
         as: :deactivate_feature
  end

  namespace :teacher_interface, path: "/teacher" do
    get "degree", to: "degrees#new"
    post "degree", to: "degrees#create"
    get "countries", to: "countries#new"
    post "countries", to: "countries#create"
    get "region", to: "region#new"
    post "region", to: "region#create"
    get "qualifications", to: "qualifications#new"
    post "qualifications", to: "qualifications#create"
    get "recognised", to: "recognised#new"
    post "recognised", to: "recognised#create"
    get "teach-children", to: "teach_children#new"
    post "teach-children", to: "teach_children#create"
    get "start", to: "pages#start"
    get "eligible", to: "pages#eligible"
    get "ineligible", to: "pages#ineligible"
    get "misconduct", to: "misconduct#new"
    post "misconduct", to: "misconduct#create"
    get "locations", to: "countries#index"

    root to: redirect("/teacher/start")
  end

  get "cookies", to: "static#cookies"

  root to: redirect("/teacher/start")
end
