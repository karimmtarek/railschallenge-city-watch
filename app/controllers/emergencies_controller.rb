class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all
    @full_responses = [Emergency.full_response, Emergency.total_number]
    render :index, status: :ok
  end

  def show
    @emergency = Emergency.find_by(code: params[:code])
    if @emergency
      render :show, status: :ok
    else
      head :not_found
    end
  end

  def create
    @emergency = Emergency.new(emergency_params)

    if unpermitted?(params[:emergency], %w(id resolved_at))
      return unpermitted(params[:emergency], %w(id resolved_at))
    end

    if @emergency.valid?
      responders_dispatch(@emergency)
      @emergency.calc_full_response
      @emergency.save
      render :new, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @emergency = Emergency.find_by(code: params[:code])

    if unpermitted?(params[:emergency], %w(code))
      return unpermitted(params[:emergency], %w(code))
    end

    if @emergency.update(emergency_params)
      release_responders
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

  def release_responders
    @emergency.release_responders if params[:emergency][:resolved_at].present?
  end
end
