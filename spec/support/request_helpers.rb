module Request
  module JsonHelpers
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end
  end

  module AuthenticationHelpers
    def token_header(resource)
      "Token token=\"#{resource.auth_token}\""
    end

    def encode_credentials(username, password)
      ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    end
  end
end
