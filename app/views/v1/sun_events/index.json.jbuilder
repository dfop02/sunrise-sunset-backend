json.array! @sun_events[:data] do |event|
  json.city event.city
  json.date event.date
  json.sunrise event.sunrise&.to_s
  json.sunset event.sunset&.to_s
  json.golden_hour event.golden_hour&.to_s
end
