Rails.application.routes.draw do
  # Used to display mailers for preview
  get '/rails/mailers' => "rails/mailers#index"
  get '/rails/mailers/*path' => "rails/mailers#preview"

  ActiveAdmin.routes(self)
  devise_for :users, ActiveAdmin::Devise.config

  scope module: :v1, constraints: ApiVersion.new('v1', true) do
    namespace :auth do
      mount_devise_token_auth_for 'User',
        defaults: { format: :json },
        controllers: {
          registrations: 'v1/registrations',
          sessions: 'v1/sessions',
          passwords: 'v1/passwords',
        }
    end
    devise_scope :user do
      post 'auth/', to: 'registrations#create'
      put 'auth/', to: 'registrations#update'
      post 'auth/:provider/sign_in', to: 'registrations#omniauth'
    end
  end
end
