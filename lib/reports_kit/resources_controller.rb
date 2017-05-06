module ReportsKit
  class ResourcesController < ReportsKit::BaseController
    def autocomplete
      results = Reports::GenerateAutocompleteResults.new(params, context_record: context_record).perform
      render json: { data: results }
    end
  end
end
