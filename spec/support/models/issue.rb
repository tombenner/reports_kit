class Issue < ActiveRecord::Base
  include ReportsKit::Model

  belongs_to :repo
  has_many :issues_labels
  has_many :labels, through: :issues_labels
  has_many :tags

  reports_kit do
    aggregation :average_duration, [:average, REPORTS_KIT_DATABASE_TYPE == :mysql ? 'DATEDIFF(closed_at, opened_at)' : '(closed_at::date - opened_at::date)']
    contextual_filter :for_repo, ->(relation, context_params) { context_params ? relation.where(repo_id: context_params[:repo_id]) : relation }
    dimension :titleized_state, group: 'issues.state', key_to_label: -> (state) { state.try(:titleize) }
  end
end
