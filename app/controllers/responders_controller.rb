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

    if unpermitted?(params[:responder], %w(emergency_code id on_duty))
      return unpermitted(params[:responder], %w(emergency_code id on_duty))
    end

    if @responder.save
      render :show, status: :created
    else
      render :error, status: :unprocessable_entity
    end
  end

  def update
    @responder = Responder.find_by(name: params[:name])

    if unpermitted?(params[:responder], %w(emergency_code type name capacity))
      return unpermitted(params[:responder], %w(emergency_code type name capacity))
    end

    if @responder.update(responder_params)
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
    @responders_capacity = Responder.all_capacity

    render :show_capacity, status: :ok
  end
end
