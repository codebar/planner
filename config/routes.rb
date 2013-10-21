Planner::Application.routes.draw do
  root "dashboard#show"

  resource :members, only: [:new, :create]

  resources :invitation, only: [] do
    member do
      get "accept"
    end
  end

end
