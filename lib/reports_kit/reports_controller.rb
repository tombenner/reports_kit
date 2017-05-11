module ReportsKit
  class ReportsController < ReportsKit::BaseController
    def index
      properties = ActiveSupport::JSON.decode(params[:properties])
      report_data = Reports::Data::Generate.new(properties, context_record: context_record).perform
      render json: { data: report_data }
    end
  end
end
