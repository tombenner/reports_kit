module ReportsKit
  class ResourcesController < ActionController::Base
    def autocomplete
      results = Reports::GenerateAutocompleteResults.new(params).perform
      results = results.map { |result| { id: result.id, text: result.to_s } }
      results = results.sort_by { |result| result[:text].downcase }
      results = filter_results_for_autocomplete(results)
      render json: { data: results }
    end

    private

    def filter_results_for_autocomplete(results)
      query = params[:q].try(:downcase)
      if query.present?
        results = results.to_a.select { |r| r[:text].downcase.include?(query) }
      end
      results
    end
  end
end
