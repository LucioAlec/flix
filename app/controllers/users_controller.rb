class UsersController < ApplicationController
  before_action :require_signin, except: [ :new, :create ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :require_correct_user, only: [ :edit, :update ]
  before_action :require_admin, only: [ :index ]
  before_action :require_admin_or_current_user, only: [ :destroy ]

  def index
    @users = User.not_admins
  end

  def show
    @reviews = @user.reviews
    @favorite_movies = @user.favorite_movies
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to @user, notice: "User sucessfully created!!!"
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit ; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Account successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    deleting_self = current_user?(@user)
    @user.destroy
    reset_session if deleting_self
    if deleting_self
      redirect_to root_url, status: :see_other, notice: "Account successfully deleted!"
    else
      redirect_to users_url, status: :see_other,
      alert: "Account sucessfully deleted!"
    end
  end


    private
    def user_params
      params.require(:user).
        permit(:name, :username, :email, :password, :password_confirmation)
    end

    def require_correct_user
      redirect_to root_url, status: :see_other unless current_user?(@user)
    end

    def set_user
      @user = User.find(params[:id])
    end
end
