class RespondersController < ApplicationController
  def index
    @responders = Responder.all
    render :index, status: :ok
  end

  def create
    @responder = Responder.new(responder_params)

    # binding.pry
    unpermitted_params_array = %w(emergency_code id on_duty)

    if unpermitted_param?(params[:responder], unpermitted_params_array)
      @unpermitted_param = unpermitted_param(params[:responder], unpermitted_params_array)
      render :unpermitted_parameter_error, status: :unprocessable_entity
    elsif @responder.save
      render :show, status: :created
    else
      render :error, status: :unprocessable_entity
    end
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def unpermitted_param?(responder_hash, params_array)
    responder_hash.any? { |key, _value| params_array.include? key }
  end

  def unpermitted_param(responder_hash, params_array)
    params_array.each do |param|
      return param.to_s if responder_hash[param].present?
    end
  end
end
