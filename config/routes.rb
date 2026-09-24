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

      resources :users, only: [] do
        collection do
          get :me
        end
      end
    end
  end
end
