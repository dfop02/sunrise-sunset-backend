class V1::SunEventsController < ApplicationController
  def index
    return render json: { error: 'Missing parameters' }, status: :bad_request if has_missing_params?

    sun_service = SunsetSunriseService.new(sun_params)
    @sun_events = sun_service.fetch_sun_day
    return render json: @sun_events, status: :unprocessable_entity if has_error?(@sun_events)

    render :index, formats: :json
  end

  private

  def sun_params
    params.permit(:city, :start_date, :end_date)
  end

  def has_error?(resp)
    resp.key?(:error)
  end

  def has_missing_params?
    sun_params[:city].blank? && sun_params[:start_date].blank? && sun_params[:end_date].blank?
  end
end
