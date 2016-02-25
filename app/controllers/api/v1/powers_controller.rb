module Api
  module V1
    class PowersController < BaseController
      def index
        @rune = Rune.find params[:rune_id]
        @powers = @rune.powers
      end

      def show
        @power = Power.find params[:id]
        authorize @power
      end

      def create
        @rune = Rune.find params[:rune_id]
        @power = @rune.powers.new power_params
        authorize @power
        return render_created(api_power_url(@power)) if @power.save
        render_errors @power
      end

      def update
        @power = Power.find params[:id]
        authorize @power
        return render_show(api_power_url(@power)) if @power.update power_params
        render_errors @power
      end

      def destroy
        @power = Power.find params[:id]
        authorize @power
        return render_nothing if @power.destroy
        render_errors @power
      end

      private

      def power_params
        params.require(:power).permit :name, :description
      end
    end
  end
end
