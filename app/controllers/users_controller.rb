class UsersController < ApplicationController
  before_action :load_user, except: %i(new create index import)
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @all_users = User.all
    @users = @all_users.sort_by_name.page(params[:page]).per(Settings.users.page.default_page)
    respond_to do |format|
      format.xlsx {
        response.headers["Forum of Gamer Community"] = "attachment; filename='Users.xlsx'"
      }
      format.html { render :index }
    end
  end

  def show
    @posts = @user.posts.sort_by_time.page(params[:page]).per Settings.posts.page.max
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".acct_info"
      redirect_to root_path
    else
      flash.now[:danger] = t ".fail_mess_create"
      render :new
    end
  end

  def update
    if @user.update user_params
      flash[:success] = t ".success_mess_update"
      redirect_to @user
    else
      flash.now[:danger] = t ".fail_mess_update"
      render :edit
    end
  end

  def edit; end

  def destroy
    if @user.destroy
      flash[:success] = t ".success_mess_delete"
    else
      flash[:warning] = t ".fail_mess_delete"
    end
    redirect_to users_path
  end


  def import
    file = params[:attachment]
    if params[:attachment].blank? || File.extname(file.original_filename) != ".xlsx"
      flash[:warning] = t ".fail_mess_import"
    elsif User.import(file)
      flash[:success] = t ".success_mess_import"
    else
      flash[:warning] = t ".warn_mess_import"
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit User::USERS_PARAMS
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "users.user_not_found"
    redirect_to root_path
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "users.login_remind"
      redirect_to login_path
    end
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
