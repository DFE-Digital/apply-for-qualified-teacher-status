Rails.application.routes.draw do
  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/422', to: 'errors#unprocessable_entity'
    get '/500', to: 'errors#internal_server_error'
  end

  namespace :support_interface, path: '/support' do
  end

  namespace :teacher_interface, path: '/teacher' do
    get 'start', to: 'pages#start'
    get 'eligible', to: 'pages#eligible'
    get 'misconduct', to: 'misconduct#new'
    post 'misconduct', to: 'misconduct#create'
    root to: redirect('/teacher/start')
  end

  root to: redirect('/teacher/start')
end
