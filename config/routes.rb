Rails.application.routes.draw do
  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/422', to: 'errors#unprocessable_entity'
    get '/500', to: 'errors#internal_server_error'
  end

  namespace :teacher_interface, path: '/teacher' do
    root to: 'pages#start'
  end

  root to: 'pages#home'
end
