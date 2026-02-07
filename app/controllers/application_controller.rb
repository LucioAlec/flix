class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  add_flash_types(:danger)

  private


  def require_signin
    unless current_user
    session[:intended_url] = request.url if request.get?
      redirect_to new_session_url, alert: "Please, you must to sign in first!"
    end
  end

    def current_user
   @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_admin
    unless current_user_admin?
      redirect_to movies_url, alert: "Unauthorized access"
    end
  end

  def require_admin_or_current_user
    redirect_to root_url, status: :see_other unless current_user_admin? || current_user?(@user)
  end

  def current_user_admin?
    current_user && current_user.admin?
  end

  helper_method :current_user_admin?

  def current_user?(user)
    current_user == user
  end
  helper_method :current_user?
end
