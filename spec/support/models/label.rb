class Label < ActiveRecord::Base
  belongs_to :repo
  has_many :issues_labels
  has_many :issues, through: :issues_labels
end
