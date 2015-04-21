class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all
    @full_responses = ['missong', Emergency.total_number]
    render :index, status: :ok
  end

  def show
    @emergency = Emergency.find_by(code: params[:code])
    # binding.pry
    if @emergency
      render :show, status: :ok
    else
      head :not_found
    end
  end

  def create
    @emergency = Emergency.new(emergency_params)

    unpermitted_params_array = %w(id resolved_at)

    if unpermitted_param?(params[:emergency], unpermitted_params_array)
      @unpermitted_param = unpermitted_param(params[:emergency], unpermitted_params_array)
      render :unpermitted_parameter_error, status: :unprocessable_entity
    elsif @emergency.save
      render :new, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @emergency = Emergency.find_by(code: params[:code])

    unpermitted_params_array = %w(code)

    if unpermitted_param?(params[:emergency], unpermitted_params_array)
      @unpermitted_param = unpermitted_param(params[:emergency], unpermitted_params_array)
      render :unpermitted_parameter_error, status: :unprocessable_entity
    elsif @emergency.update(emergency_params)
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

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :resolved_at)
  end
end
