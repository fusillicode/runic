require 'api_constraints'

Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constrains: ApiConstraints.new(version: 1) do
      resources :users, only: [:index, :show, :update, :destroy] do
        get :token, on: :collection
      end
      resources :runes
      match '*unmatched_route', controller: 'base', to: '#routing_error', via: :all
    end
  end
end
