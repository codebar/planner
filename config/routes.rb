Planner::Application.routes.draw do
  root "dashboard#show"

  get "code-of-conduct" => "dashboard#code", as: :code_of_conduct
  get "wall-of-fame" => "dashboard#wall_of_fame", as: :wall_of_fame

  resource :members, only: [:new, :create]

  resources :members, only: [] do
    member do
      get "unsubscribe"
    end
  end

  resources :invitation, only: [] do
    member do
      get "accept"
      get "reject"
    end
  end

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

end
