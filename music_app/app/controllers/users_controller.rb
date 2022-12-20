class UsersController < ApplicationController
    # reddit example equivalent sign up form

    def new
        @user = User.new
        render :new
    end

    def create
        @user = User.create(user_params)
        if @user.save!
            login!(@user)
            redirect_to user_url(@user)
        else
            flash.now[:errors] = @user.errors.full_messages
            render :new
        end
    end

    def show
        @user = User.find(user_params[:id])
        render :show
    end

    private

    def user_params
        params.require(:user).permit(:email, :password)
    end
end
