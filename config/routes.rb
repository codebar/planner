Planner::Application.routes.draw do
  root "dashboard#show"

  get "code-of-conduct" => "dashboard#code", as: :code_of_conduct

  resource :members, only: [:new, :create]

  resources :members, only: [] do
    member do
      get "unsubscribe"
    end
  end

  resources :invitation, only: [] do
    member do
      get "accept"
    end
  end

  namespace :course do
    resources :invitation, only: [] do
      member do
        get "accept"
      end
    end
  end

  resources :courses, only: [:index, :show]

end
