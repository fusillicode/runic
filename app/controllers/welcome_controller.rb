class WelcomeController < ApplicationController
  def index
    redirect_to '/rails/info'
  end
end
