class Repo < ActiveRecord::Base
  include ReportsKit::Model

  has_many :issues

  reports_kit do
    contextual_filter :for_repo, ->(relation, context_params) { context_params ? relation.where(id: context_params[:repo_id]) : relation }
  end

  def to_s
    full_name
  end
end
