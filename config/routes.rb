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

    root to: redirect('/teacher/start')
  end
end
