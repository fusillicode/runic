module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate, except: :token

      def index
        @users = User.where.not id: current_user
      end

      def show
        @user = User.find params[:id]
      end

      def token
        return render_token if authenticate_from_username_and_password
        render_unauthorized
      end

      def update
        @user = User.find params[:id]
        authorize @user
        return render_show(api_user_url(@user)) if @user.update user_params
        render_errors @user
      end

      def destroy
        @user = User.find params[:id]
        authorize @user
        return render_nothing if @user.destroy
        render_errors @user
      end

      private

      def user_params
        params.require(:user).permit :username, :password
      end
    end
  end
end
