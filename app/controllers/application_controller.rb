class ApplicationController < ActionController::API
  protect_from_forgery with: :exception

  protected

  def bug_api
    @bug_api ||= App.find_by_authentication_token(params[:app_token] || request.headers["X-App-Token"])
  end

end
