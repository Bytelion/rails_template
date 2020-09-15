class ApplicationController < ActionController::Base
  include Response
  include ExceptionHandler

  protect_from_forgery unless: -> { request.format.json? }

  def authenticate_admin_user!
    if current_user.present? && current_user.admin?
      authenticate_user!
    elsif current_user.present?
      sign_out(current_user)
      flash[:alert] = ErrorMessage.admin_unauthorized
      redirect_to new_user_session_path
    else
      redirect_to root_path
    end
  end

  def current_admin_user
    current_user
  end

  protected

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
