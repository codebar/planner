Planner::Application.routes.draw do
  root "dashboard#show"

  scope controller: 'dashboard' do
    get 'code-of-conduct', action: 'code'
    get 'coaches', action: 'wall_of_fame'
    get 'effective-teacher-guide', action: 'effective-teacher-guide', as: :teaching_guide
    get 'faq', action: 'faq'
    get 'attendance-policy', action: 'attendance_policy'
    get 'dashboard', action: 'dashboard'
    get 'student-guide', action: 'participant_guide'
  end

  resource :member, only: [:new, :edit, :update, :patch] do
    get 'step1'
    put 'step1'
    get 'step2'
  end

  resource :members do
    get :autocomplete_skill_name, on: :collection
  end

  get '/profile' => "members#profile", as: :profile

  resources :subscriptions, only: [:index, :create]
  delete '/subscriptions' => 'subscriptions#destroy', as: :destroy_subscriptions

  get "unsubscribe/:token" => "members#unsubscribe", as: :unsubscribe

  resources :invitation, only: [:show] do
    member do
      post "accept_with_note", as: :accept_with_note
      post "update_note"
      get "accept"
      get "reject"
    end

    resource :waiting_list, only: [:create, :destroy]
  end

  resources :invitations, only: [:index]

  resources :meetings, only: [:show] do
    get 'invitation/attend' => 'invitations#rsvp_meeting', as: :invitation
    get 'invitation/:token/cancel' => 'invitations#cancel_meeting', as: :cancel
  end

  namespace :course do
    resources :invitation, only: [:show] do
      member do
        get "accept"
        get "reject"
      end
    end
  end

  resources :events, only: [:index, :show] do
    post 'rsvp'
    get 'student', as: :student_rsvp
    get 'coach', as: :coach_rsvp
    get 'invitation/:token' => 'invitations#show', as: :invitation
    post 'invitation/:token/attend' => 'invitations#attend', as: :attend
    post 'invitation/:token/reject' => 'invitations#reject', as: :reject
  end

  resources :courses, only: [:show] do
    get "rsvp"
  end
  resources :workshops, only: [:show] do
    member do
      post 'rsvp'
    end
  end
  resources :feedback, only: [:show] do
    member do
      patch "submit"
      get "success"
      get "not_found"
    end
  end

  resources :jobs, except: [:destroy] do
    get 'preview'
    post 'submit'
    get 'pending', on: :collection
  end

  resources :skills, only: [:show]


  namespace :admin do
    root "portal#index"

    get '/guide' => "portal#guide", as: :guide


    resources :jobs, only: [:index, :show] do
      get 'all', on: :collection
      get 'approve'
    end

    resources :announcements, only: [:new, :index, :create, :edit, :update]
    resources :members, only: [:show, :index] do
      get :send_eligibility_email
      get :send_attendance_email
      get :update_subscriptions
      resources :bans, only: [:index, :new, :create]
    end
    resources :member_notes, only: [:create]

    resources :chapters, only: [:index, :new, :create, :show, :edit, :update] do
      get :members
      resources :workshops, only: [:index]
    end

    resources :events, only: [:new, :create, :show, :edit, :update] do
      get 'attendees_emails'
      post 'invite'
      resources :invitation do
        post 'verify'
        post 'cancel'
      end
    end

    resources :invitation, only: [:update]

    resources :meetings do
      member do
        get 'attendees_emails'
        get 'invite'
      end
    end

    resources :meeting_invitations, only: [:create, :update]

    resources :groups, only: [:index, :new, :create, :show]
    resources :sponsors, except: [:destroy]

    resources :feedback, only: [:index]
    resources :workshops do
      post :host
      delete 'host', action: 'destroy_host', as: :destroy_host
      post :sponsor
      delete 'sponsor', action: 'destroy_sponsor', as: :destroy_sponsor
      post :invite
      get 'attendees_checklist'
      get 'attendees_emails'
      get 'send_invites'

      resource :invitations, only: [:update]
      resources :invitations, only: [:update]

    end
  end

  namespace :coach do
    resources :feedback, only: [:index]
  end

  get   '/login', to: 'auth_services#new'
  match '/auth/:service/callback' => 'auth_services#create', via: %i(get post)
  match '/auth/failure' => 'auth_services#failure', via: %i(get post)
  match '/logout' => 'auth_sessions#destroy', via: %i(get delete), as: :logout
  match '/register' => 'auth_sessions#create', via: %i(get), as: :registration

  resources :sponsors, only: [:index]
  resources :donations, only: [:new, :create]

  get ':id' => 'chapter#show', as: :chapter
end
