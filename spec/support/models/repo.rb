class Repo < ActiveRecord::Base
  has_many :issues

  def to_s
    full_name
  end
end
