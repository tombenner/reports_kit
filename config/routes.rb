ReportsKit::Engine.routes.draw do
  namespace :reports_kit do
    resources :reports, only: [:index]
  end
end
