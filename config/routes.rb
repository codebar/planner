Planner::Application.routes.draw do
  root "dashboard#show"

  get "code-of-conduct" => "dashboard#code", as: :code_of_conduct
  get "wall-of-fame" => "dashboard#wall_of_fame", as: :wall_of_fame

  resource :member, only: [:new, :edit, :update] do
    member do
      get "unsubscribe"
    end
  end

  resources :invitation, only: [ :show ] do
    member do
      get "accept"
      get "reject"
    end
  end

  resources :portal, only: [ :index ]

  namespace :course do
    resources :invitation, only: [] do
      member do
        get "accept"
        get "reject"
      end
    end
  end

  resources :courses, only: [ :index, :show ]
  resources :sessions, only: [ :index ]
  resources :meetings, only: [ :show ]

  namespace :admin do
    root "portal#index"
  end

  match '/auth/:service/callback' => 'auth_services#create', via: %i(get post)
  match '/auth/failure' => 'auth_services#failure', via: %i(get post)
  match '/logout' => 'auth_sessions#destroy', via: %i(get delete), as: :logout
end
