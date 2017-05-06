class Issue < ActiveRecord::Base
  belongs_to :repo
  has_many :issues_labels
  has_many :labels, through: :issues_labels
end
