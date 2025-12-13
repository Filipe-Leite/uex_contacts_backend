class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :skip_session
  
  private
  
  def skip_session
    request.session_options[:skip] = true
  end
end