class GeocodeService
  # API Source: https://geocode.maps.co/
  def initialize(city)
    @base_url = 'https://geocode.maps.co/search'.freeze
    @api_key = ENV['GEOCODE_API_KEY']
    @city = city
  end

  def get_coordinates
    uri = URI(@base_url)
    uri.query = URI.encode_www_form({
      city: @city,
      api_key: @api_key,
      formatted: 0
    })

    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)

    json_body = JSON.parse(res.body)
    { lat: json_body.first['lat'], lng: json_body.first['lon'] }
  end
end
