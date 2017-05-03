module ReportsKit
  class ResourcesController < ActionController::Base
    def autocomplete
      results = Reports::GenerateAutocompleteResults.new(params).perform
      render json: { data: results }
    end
  end
end
