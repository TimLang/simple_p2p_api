
module Concerns::LinaAuthConcern
  extend ActiveSupport::Concern
  included do

    def lina_custom_auth
      authenticate_or_request_with_http_basic do |username, password|
        username == "tim" && password == "111111"
      end
    end

  end
end


