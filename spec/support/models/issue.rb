class Issue < ActiveRecord::Base
  include ReportsKit::Model

  belongs_to :repo
  has_many :issues_labels
  has_many :labels, through: :issues_labels
  has_many :tags

  reports_kit do
    dimension :titleized_state, group: 'issues.state', key_to_label: -> (state) { state.try(:titleize) }
  end
end
