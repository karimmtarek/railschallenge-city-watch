class RespondersController < ApplicationController
  def index
    @responders = Responder.all

    return responders_capacity if params[:show] == 'capacity'

    render :index, status: :ok
  end

  def show
    @responder = Responder.find_by(name: params[:name])

    if @responder
      render :show, status: :ok
    else
      head :not_found
    end
  end

  def create
    @responder = Responder.new(responder_params)

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

  def update
    @responder = Responder.find_by(name: params[:name])

    unpermitted_params_array = %w(emergency_code type name capacity)

    if unpermitted_param?(params[:responder], unpermitted_params_array)
      @unpermitted_param = unpermitted_param(params[:responder], unpermitted_params_array)
      render :unpermitted_parameter_error, status: :unprocessable_entity
    elsif @responder.update(responder_params)
      render :show, status: :ok
    else
      head :unprocessable_entity
    end
  end

  def new
  end

  def edit
  end

  def destroy
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity, :on_duty, :emergency_code)
  end

  def not_found
    render :not_found, status: :not_found
  end

  def responders_capacity
    @types = Responder.types

    @responders_capacity  = []
    responder_capacity = []

    @types.each do |type|
      total_capacity = Responder.total_capacity_by(type)
      available_capacity = Responder.total_available_capacity_by(type)
      on_duty_capacity = Responder.total_on_duty_capacity_by(type)
      available_on_duty_capacity = Responder.total_available_on_duty_capacity_by(type)

      responder_capacity << total_capacity << available_capacity << on_duty_capacity << available_on_duty_capacity
      @responders_capacity << responder_capacity
      responder_capacity = []
    end

    render :show_capacity, status: :ok
  end
end
