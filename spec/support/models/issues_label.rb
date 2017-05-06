class IssuesLabel < ActiveRecord::Base
  belongs_to :issue
  belongs_to :label
end
