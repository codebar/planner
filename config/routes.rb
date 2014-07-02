Planner::Application.routes.draw do
  root "dashboard#show"

  get "code-of-conduct" => "dashboard#code", as: :code_of_conduct
  get "coaches" => "dashboard#wall_of_fame", as: :coaches
  get "sponsoring" => "dashboard#sponsoring", as: :sponsoring
  get "effective-teacher-guide" => "dashboard#effective-teacher-guide", as: :teaching_guide
  get "faq" => "dashboard#faq"

  resource :member, only: [:new, :edit, :update, :patch]

  get '/profile' => "members#profile", as: :profile

  resources :subscriptions, only: [ :index, :create ]
  delete '/subscriptions' => 'subscriptions#destroy', as: :destroy_subscriptions

  resources :members, only: [] do
    member do
      get "unsubscribe"
    end
  end

  resources :invitation, only: [ :show ] do
    member do
      post "accept_with_note", as: :accept_with_note
      get "accept"
      get "reject"
    end
  end

  resources :invitations, only: [ :index ]

  namespace :course do
    resources :invitation, only: [:show] do
      member do
        get "accept"
        get "reject"
      end
    end
  end

  resources :events, only: [ :index ]
  resources :courses, only: [ :show ]
  resources :meetings, only: [ :show ]
  resources :feedback, only: [ :show ] do
    member do
      patch "submit"
      get "success"
      get "not_found"
    end
  end

  resources :jobs, except: [:destroy] do
    get 'preview'
    get 'submit'
    get 'pending', on: :collection
  end

  namespace :admin do
    root "portal#index"

    resources :jobs, only: [ :index, :show] do
      get 'approve'
    end

    resources :members, only: [:show]

    resources :chapters, only: [ :index, :new, :create, :show] do
      resources :workshops, only: [ :index ]
    end

    resources :groups, only: [ :index, :new, :create, :show]
    resources :sponsors, only: [:new, :edit, :update, :show, :create]

    resources :invitation, only: [] do
      get :attended
      get :not_attending
    end

    resources :feedback, only: [:index]
    resources :workshops do
      post :host
      delete '/host' => "workshops#destroy_host", as: :destroy_host
      post :sponsor
      delete '/sponsor' => "workshops#destroy_sponsor", as: :destroy_sponsor
      post :invite
    end
    resources :sponsors, only: [:new, :create]
  end

  namespace :coach do
    resources :feedback, only: [ :index ]
  end

  match '/auth/:service/callback' => 'auth_services#create', via: %i(get post)
  match '/auth/failure' => 'auth_services#failure', via: %i(get post)
  match '/logout' => 'auth_sessions#destroy', via: %i(get delete), as: :logout
  match '/register' => 'auth_sessions#create', via: %i(get), as: :registration
end
