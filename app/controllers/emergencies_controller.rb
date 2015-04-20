class EmergenciesController < ApplicationController
  def create
    @emergency = Emergency.new(emergency_params)

    unpermitted_params_array = %w(id resolved_at)

    if unpermitted_param?(params[:emergency], unpermitted_params_array)
      @unpermitted_param = unpermitted_param(params[:emergency], unpermitted_params_array)
      render :unpermitted_parameter_error, status: :unprocessable_entity
    elsif @emergency.save
      render :show, status: :created
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end
end
