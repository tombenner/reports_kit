ReportsKit::Engine.routes.draw do
  namespace :reports_kit do
    resources :reports, only: [:index]
    resources :resources, only: [] do
      collection do
        get 'measures/:measure_key/filters/:filter_key/autocomplete' => :autocomplete
      end
    end
  end
end
