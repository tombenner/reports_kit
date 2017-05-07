if Rails.version >= '3.1'
  require 'reports_kit/engine'
else
  ActionView::Base.send :include, Chartkick::Helper
end
