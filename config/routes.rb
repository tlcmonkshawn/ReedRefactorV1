Rails.application.routes.draw do
  # Root route
  root 'root#index'

  # Admin interface (HTML pages)
  namespace :admin do
    root 'dashboard#index'

    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'

    resources :logs, only: [:index, :show]
    resources :users
    resources :locations
    resources :items, only: [:index, :show, :edit, :update, :destroy]
    resources :prompts
  end

  # API endpoints (JSON)
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'
      post 'auth/refresh', to: 'auth#refresh'

      # Locations
      resources :locations, only: [:index, :show, :create, :update, :destroy]

      # Booties (Items)
      resources :booties, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'finalize', to: 'booties#finalize'
          post 'research', to: 'booties#trigger_research'
          get 'research', to: 'booties#research_results'
          get 'research/logs', to: 'booties#research_logs'
          get 'research/sources', to: 'booties#grounding_sources'
        end
      end

      # Categories
      resources :categories, only: [:index]

      # Image Upload & Processing
      post 'images/upload', to: 'images#upload'
      post 'images/process', to: 'images#process'
      post 'images/analyze', to: 'images#analyze'

      # Conversations & Messages
      resources :conversations, only: [:index, :show, :create] do
        resources :messages, only: [:index, :create]
      end

      # Gemini Live API
      post 'gemini_live/session', to: 'gemini_live#create_session'
      post 'gemini_live/tool_call', to: 'gemini_live#tool_call'

      # Gamification
      resources :leaderboards, only: [:index] do
        collection do
          get 'daily', to: 'leaderboards#daily'
          get 'weekly', to: 'leaderboards#weekly'
          get 'monthly', to: 'leaderboards#monthly'
          get 'overall', to: 'leaderboards#overall'
        end
      end

      resources :scores, only: [:index, :show]
      resources :achievements, only: [:index, :show]

      # Game Modes
      post 'game_modes/scour/start', to: 'game_modes#start_scour'
      post 'game_modes/scour/complete', to: 'game_modes#complete_scour'
      post 'game_modes/locus/start', to: 'game_modes#start_locus'
      post 'game_modes/locus/complete', to: 'game_modes#complete_locus'
      get 'game_modes/tag/current', to: 'game_modes#current_tag'

      # Social Sharing
      post 'booties/:id/share', to: 'booties#share'

      # System Configuration
      get 'config', to: 'config#show'
      put 'config', to: 'config#update'

      # Prompts (Bootie Bosses and Admins can manage)
      resources :prompts, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'get', to: 'prompts#get' # GET /api/v1/prompts/get?category=...&name=...
          get 'by_category/:category', to: 'prompts#by_category'
        end
      end

      # Prompt Cache
      get 'prompt_cache/check_updates', to: 'prompt_cache#check_updates'
      get 'prompt_cache/stats', to: 'prompt_cache#stats'
    end
  end

  # Health check
  get 'health', to: 'health#check'
  get 'health/test_register', to: 'health#test_register'
  
  # Migration endpoints (one-time use, password protected)
  get 'migrations/status', to: 'migrations#status'
  post 'migrations/run', to: 'migrations#run'
  post 'migrations/schema_load', to: 'migrations#schema_load'
  get 'migrations/export_locations', to: 'migrations#export_locations'
  post 'migrations/restore_locations', to: 'migrations#restore_locations'
end
