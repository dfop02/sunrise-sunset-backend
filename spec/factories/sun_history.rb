FactoryBot.define do
  factory :sun_history do
    city { "lisbon" }
    date { Date.today }
    sunrise { Time.now }
    sunset { Time.now + 6.hours }
    golden_hour { Time.now + 1.hour }
  end
end
