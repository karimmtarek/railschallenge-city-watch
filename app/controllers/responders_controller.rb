class RespondersController < ApplicationController
  def index
    @responders = Responder.all

    if params[:show] == 'capacity'
      @types = types(@responders)
      return render :show_capacity, status: :ok
    end

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

  def types(source)
    types_array = []
    source.each do |responder|
      types_array << responder.type unless types_array.include? responder.type
    end
    types_array
  end

  def not_found
    render :not_found, status: :not_found
  end
end
