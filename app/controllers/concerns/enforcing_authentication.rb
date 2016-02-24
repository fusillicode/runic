module Concerns
  module EnforcingAuthentication
    extend ActiveSupport::Concern

    included do
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include ActionController::HttpAuthentication::Basic::ControllerMethods

      before_action :destroy_session
      before_action :authenticate

      attr_reader :current_user
    end

    private

    def destroy_session
      request.session_options[:skip] = true
    end

    def authenticate
      authenticate_from_token || render_unauthorized
    end

    def authenticate_from_token
      authenticate_with_http_token do |token, _options|
        @current_user = User.find_by auth_token: token
      end
    end

    def authenticate_from_username_and_password
      authenticate_with_http_basic do |username, password|
        @current_user = User.find_by username: username
        current_user && current_user.authenticate(password)
      end
    end
  end
end
