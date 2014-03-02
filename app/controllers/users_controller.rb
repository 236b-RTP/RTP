class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      flash[:success] = "Your user account has been created. You may now sign in."
      redirect_to new_user_session_path
    else
      flash.now[:error] = "<ol><li>#{@user.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :new
    end
  end

  def destroy
  end

  def edit
  end

  def update
  end

  private

  def new_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
