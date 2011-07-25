# Fix rack UTF-8 warnings, and make escaping faster at the same time
# http://openhood.com/ruby/rack/2010/07/15/rack-test-warning/
module Rack
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s)
    end
  end
end

