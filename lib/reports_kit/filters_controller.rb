module ReportsKit
  class FiltersController < ReportsKit::BaseController
    before_action :modify_context_params

    def autocomplete
      properties = Reports::Properties.generate(self)
      results = Reports::GenerateAutocompleteResults.new(params, properties, context_record: context_record).perform
      render json: { data: results }
    end
  end
end
