Planner::Application.routes.draw do
  root "dashboard#show"

  scope controller: 'dashboard' do
    get 'code-of-conduct', action: 'code'
    get 'coaches', action: 'wall_of_fame'
    get 'sponsoring', action: 'sponsoring'
    get 'effective-teacher-guide', action: 'effective-teacher-guide', as: :teaching_guide
    get 'faq', action: 'faq'
    get 'attendance-policy', action: 'attendance_policy'
  end

  resource :member, only: [:new, :edit, :update, :patch]

  get '/profile' => "members#profile", as: :profile

  resources :subscriptions, only: [ :index, :create ]
  delete '/subscriptions' => 'subscriptions#destroy', as: :destroy_subscriptions

  get "unsubscribe/:token" => "members#unsubscribe", as: :unsubscribe

  resources :invitation, only: [ :show ] do
    member do
      post "accept_with_note", as: :accept_with_note
      get "accept"
      get "reject"
    end

    resource :waiting_list, only: [:create, :destroy]
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

  resources :events, only: [ :index, :show ] do
    get 'student', as: :student_rsvp
    get 'coach', as: :coach_rsvp
    get 'invitation/:token' => 'invitations#show', as: :invitation
    post 'invitation/:token/attend' => 'invitations#attend', as: :attend
    post 'invitation/:token/reject' => 'invitations#reject', as: :reject
  end

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

    resources :events, only: [:show] do
      resources :invitation do
        post 'verify'
        post 'cancel'
      end
    end

    resources :groups, only: [ :index, :new, :create, :show]
    resources :sponsors, except: [:destroy]

    resources :invitation, only: [] do
      get :attended
      post :not_attending
    end

    resources :feedback, only: [:index]
    resources :workshops do
      post :host
      delete 'host', action: 'destroy_host', as: :destroy_host
      post :sponsor
      delete 'sponsor', action: 'destroy_sponsor', as: :destroy_sponsor
      post :invite
    end
  end

  namespace :coach do
    resources :feedback, only: [ :index ]
  end

  match '/auth/:service/callback' => 'auth_services#create', via: %i(get post)
  match '/auth/failure' => 'auth_services#failure', via: %i(get post)
  match '/logout' => 'auth_sessions#destroy', via: %i(get delete), as: :logout
  match '/register' => 'auth_sessions#create', via: %i(get), as: :registration

  resources :sponsors, only: [:index]
  get ':id' => 'chapter#show', as: :chapter
end
