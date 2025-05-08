class SunsetSunriseService
  def initialize(params)
    @base_url = 'https://api.sunrisesunset.io/json'.freeze
    @city = params[:city].to_s.strip.downcase
    @start_date = Date.parse(params[:start_date])
    @end_date = Date.parse(params[:end_date])
    @coordinates = get_coordinates
  end

  def fetch_sun_day
    return { error: 'Start date cannot be after end date' } if @start_date > @end_date
    return { error: 'Invalid location' } if @coordinates.blank?

    existing_histories = SunHistory.where(city: @city, date: @start_date..@end_date).index_by(&:date)
    response = []

    (@start_date..@end_date).each do |date|
      if existing_histories[date]
        response << existing_histories[date]
        next
      end

      sun_data = fetch_sun_data(@coordinates[:lat], @coordinates[:lng], date)
      return { error: "API request failed for #{date}" } if failed_response?(sun_data)

      result = sun_data['results']

      sun_history = SunHistory.create!(
        city: @city,
        date: date,
        sunrise: result['sunrise'],
        sunset: result['sunset'],
        golden_hour: result['golden_hour']
      )

      response << sun_history
    rescue => e
      return { error: e.message }
    end

    { data: response }
  end

  private

  def geocode_city(city)
    # Hardcoded for tests purposes
    # Uncomment next line to use real data API
    # return nil
    {
      'lisbon' => { lat: 38.7169, lng: -9.1399 },
      'berlin' => { lat: 52.52, lng: 13.405 },
      'antarctica' => { lat: -72.822042, lng: 0},
      'rio de janeiro' => { lat: -22.9110137, lng: -43.2093727 }
    }[city]
  end

  def fetch_sun_data(lat, long, date)
    uri = URI(@base_url)
    uri.query = URI.encode_www_form({
      lat: lat,
      lng: long,
      date: date.to_s,
      formatted: 0
    })

    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)
  end

  def get_coordinates
    geocode_city(@city) # Mock Locations
    # GeocodeService.new(@city).get_coordinates # Real Locations (Needs API KEY)
  end

  def failed_response?(resp)
    resp.nil? || resp['status'] != 'OK'
  end
end
