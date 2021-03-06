class UsersController < ApplicationController
  include PasswordResets

  before_action :require_login,      only: [:edit, :update, :upload_avatar]
  before_action :find_user,          only: [:show, :edit, :update, :upload_avatar]
  before_action :is_current_user,    only: [:edit, :update, :upload_avatar]
  before_action :contributions_list, only: [:show]
  before_action :following_list,     only: [:show]
  before_action :activities_list,    only: [:show]
  before_action :imports_list,       only: [:show]

  def new
    @user = User.new
    render layout: nil if request.xhr?
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      render json: { redirect: created_users_path }
    else
      render json: { errors: @user.errors.messages }, status: :unprocessable_entity
    end
  end

  def created
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      redirect_to root_path, notice: t('users.flash.activated')
    else
      flash[:error] = t('users.flash.activation_error')
      not_authenticated
    end
  end

  def show
  end

  def edit
  end

  def update
    save_object @user, user_params
  end

  def upload_avatar
    @user.avatar = user_params[:avatar]
    if @user.valid? && @user.save
      EventBus.publish "user_updated", user: @user, current_user: current_user, changes: {'avatar'=>[]}
      render json: {avatar: @user.avatar.url, flash: flash_xhr(t "flash.file_uploaded")}
    else
      render json: {errors: @user.errors.messages}, status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation,
                                   :license_aggrement, :about_me, :avatar).tap do |whitelisted|
        whitelisted[:contacts]  = cleaned_contacts params[:user]
        whitelisted[:interests] = cleaned_tags params[:user], :interests
        whitelisted[:location]  = cleaned_location params[:user]
      end
    end

    def find_user
      @user = User.find(params[:id])
    end

    def is_current_user
      redirect_to(root_path, notice: t('access_denied')) if @user != current_user
    end

    def contributions_list
      @contributions ||= paginate @user.try(:contributions), params[:contributions_page]
    end

    def following_list
      @following ||= paginate @user.try(:following), params[:following_page]
    end

    def activities_list
      @activities ||= paginate @user.try(:activities_performed), params[:activities_page]
    end

    def imports_list
      @imports ||= paginate @user.try(:imports), params[:imports_page]
    end
end
