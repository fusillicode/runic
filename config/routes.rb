require 'api_constraints'

Rails.application.routes.draw do
  root to: 'welcome#index'

  namespace :api, defaults: { format: 'json' } do
    get '/', to: '/welcome#index', via: :all

    scope module: :v1, constrains: ApiConstraints.new(version: 1) do
      resources :users, except: %i(new create edit) do
        get :token, on: :collection
      end
      resources :runes, except: %i(new edit) do
        resources :powers, except: %i(new edit), shallow: true
      end
    end

    get '*unmatched_route', to: 'base#routing_error', via: :all
  end
end
