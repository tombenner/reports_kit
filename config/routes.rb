ReportsKit::Engine.routes.draw do
  namespace :reports_kit do
    resources :reports, only: [:index]
    resources :filters, only: [], param: :key do
      member do
        get :autocomplete
      end
    end
  end
end
