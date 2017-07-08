require 'csv'

module ReportsKit
  class ReportsController < ReportsKit::BaseController
    def index
      properties = ActiveSupport::JSON.decode(params[:properties])
      respond_to do |format|
        format.json do
          report_data = Reports::Data::Generate.new(properties, context_record: context_record).perform
          render json: { data: report_data }
        end
        format.csv do
          properties[:format] = 'table'
          report_data = Reports::Data::Generate.new(properties, context_record: context_record).perform
          csv = CSV.generate do |csv|
            report_data[:table_data].each do |row|
              csv << row
            end
          end
          send_data csv, filename: "Report.csv"
        end
      end
    end
  end
end
