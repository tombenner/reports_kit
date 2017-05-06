module ReportsKit
  class ReportsController < ReportsKit::BaseController
    def index
      report_data = Reports::GenerateData.new(params[:properties], context_record: context_record).perform
      render json: { data: report_data }
    end
  end
end
