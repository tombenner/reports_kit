module ReportsKit
  class ReportsController < ActionController::Base
    def index
      report_data = Reports::GenerateData.new(params[:properties]).perform
      render json: { data: report_data }
    end
  end
end
