require 'api_constraints'

Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constrains: ApiConstraints.new(version: 1) do
      resources :users, except: %i(new create edit) do
        get :token, on: :collection
      end
      resources :runes, except: %i(new edit) do
        resources :powers, except: %i(new edit), shallow: true
      end
      match '*unmatched_route', controller: 'base', to: '#routing_error', via: :all
    end
  end
end
