Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get '/', to: 'home#index'
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :validation_codes, only: [:create]
      resources :session, only: [:create, :destroy]
      resources :me, only: [:index]
      resources :items do
        collection do
          get :summary
        end
      end
      resources :fetch_tags
    end
  end
end
