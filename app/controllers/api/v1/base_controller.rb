module Api
  module V1
    class BaseController < ApplicationController
      include Pundit
      include Concerns::EnforcingAuthentication
      include Concerns::RescuingRouting
      include Concerns::RenderingResponses
      protect_from_forgery with: :null_session
    end
  end
end
