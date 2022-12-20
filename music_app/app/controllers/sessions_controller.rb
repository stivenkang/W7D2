class SessionsController < ApplicationController
    # reddit example login form

    before_action :require_logged_out, only: [:new, :create]
    before_action :require_logged_in, only: [:destroy]

    def new
        @user = User.new
        render :new
    end

    def create
        email = params[:user][:email]
        password = params[:user][:password]
        @user = User.find_by_credentials(email, password)

        if @user
            login!(@user)
            redirect_to user_url(@user)
        else
            @user = User.new(email: email, password: password)
            # double check later on ^ what it does
            flash.now[:errors] = ["Invalid Credentials"]
            render :new
        end
    end

    def destroy #logging out
        if logged_in?
            logout!
        end

        # flash[:messages] = ["Successfully logged out!"]
        redirect_to new_session_url
    end
end
