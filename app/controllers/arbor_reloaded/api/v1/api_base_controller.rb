module ArborReloaded
  module Api
    module V1
      class ApiBaseController < ActionController::Base
        protect_from_forgery with: :null_session
        skip_before_filter :verify_authenticity_token
        before_action :restrict_access

        respond_to :json

        protected

        def restrict_access
          authenticate_or_request_with_http_token do |token|
            @api_key = ApiKey.find_by_access_token(token)
            ApiKey.exists?(access_token: token)
          end
        end
      end
    end
  end
end
