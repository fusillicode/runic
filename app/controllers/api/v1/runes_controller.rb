module Api
  module V1
    class RunesController < BaseController
      def index
        @runes = Rune.all
      end

      def show
        @rune = Rune.find params[:id]
        authorize @rune
      end

      def create
        @rune = current_user.runes.new rune_params
        authorize @rune
        return render_created(api_rune_url(@rune)) if @rune.save
        render_errors @rune
      end

      def update
        @rune = Rune.find params[:id]
        authorize @rune
        return render_show(api_rune_url(@rune)) if @rune.update rune_params
        render_errors @rune
      end

      def destroy
        @rune = Rune.find params[:id]
        authorize @rune
        return render_nothing if @rune.destroy
        render_errors @rune
      end

      private

      def rune_params
        params.require(:rune).permit :name, :description
      end
    end
  end
end
