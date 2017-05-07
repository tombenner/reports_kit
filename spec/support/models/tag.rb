class Tag < ActiveRecord::Base
  belongs_to :repo
  belongs_to :issue
end
