# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Registers the :user Devise mapping (defines authenticatable/current_user helpers).
  # All Devise HTTP routes are skipped — auth is JSON-only under /api/v1.
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"

      resources :users, only: %i[index show create update destroy] do
        collection do
          get :me
        end

        member do
          post :confirm
        end

        resource :face, only: %i[show create destroy], controller: "face_embeddings"
      end

      post "attendance/clock", to: "attendance#clock"
      get "attendance/events", to: "attendance_events#index"

      resources :roles, only: %i[index show create update destroy]
      resources :record_types, only: %i[index show create update destroy]
      resources :permission_rules, only: %i[index show create update destroy]
      resources :record_entries, only: %i[index show create update destroy]
      post "pdf_extractions", to: "pdf_extractions#create"
    end
  end
end
