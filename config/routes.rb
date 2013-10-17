Planner::Application.routes.draw do
  root "dashboard#show"

  resource :members, only: [:new, :create]

end
