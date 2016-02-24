module Concerns
  module RescuingRouting
    extend ActiveSupport::Concern

    included do
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound,
                  ActionController::RoutingError, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_bad_request
    end

    def routing_error
      raise ActionController::RoutingError.new("No route match #{params[:unmatched_route]}")
    end
  end
end
