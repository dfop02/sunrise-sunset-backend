require 'rails_helper'
require 'net/http'

RSpec.describe SunsetSunriseService, type: :service do
  let(:valid_params) do
    {
      city: 'Lisbon',
      start_date: '2024-01-01',
      end_date: '2024-01-02'
    }
  end

  let(:sun_data_response) do
    {
      'status' => 'OK',
      'results' => {
        'sunrise' => '2024-01-01T07:00:00+00:00',
        'sunset' => '2024-01-01T17:00:00+00:00',
        'golden_hour' => '2024-01-01T16:00:00+00:00'
      }
    }
  end

  before do
    allow(Net::HTTP).to receive(:get_response).and_return(
      instance_double(Net::HTTPSuccess, is_a?: true, body: sun_data_response.to_json)
    )
  end

  context 'when all data is already in the DB' do
    before do
      (Date.parse(valid_params[:start_date])..Date.parse(valid_params[:end_date])).each do |date|
        create(:sun_history, city: valid_params[:city].downcase, date: date)
      end
    end

    it 'returns data from the database only' do
      service = SunsetSunriseService.new(valid_params)
      result = service.fetch_sun_day

      expect(result[:data].size).to eq(2)
      expect(result[:data].all? { |h| h.city == valid_params[:city].downcase }).to be true
    end
  end

  context 'when data is not in DB' do
    it 'fetches data from the API and saves it' do
      service = SunsetSunriseService.new(valid_params)
      result = service.fetch_sun_day

      expect(result[:data].size).to eq(2)
      expect(SunHistory.count).to eq(2)
      expect(result[:data].first.city).to eq(valid_params[:city].downcase)
    end
  end

  context 'when city is invalid' do
    it 'returns an error' do
      params = valid_params.merge(city: 'invalidcity')
      service = SunsetSunriseService.new(params)
      result = service.fetch_sun_day

      expect(result).to have_key(:error)
      expect(result[:error]).to eq('Invalid location')
    end
  end

  context 'when start_date is after end_date' do
    it 'returns an error' do
      params = valid_params.merge(start_date: '2024-01-03', end_date: '2024-01-01')
      service = SunsetSunriseService.new(params)
      result = service.fetch_sun_day

      expect(result).to have_key(:error)
      expect(result[:error]).to eq('Start date cannot be after end date')
    end
  end

  context 'when the API response is invalid' do
    it 'returns an error' do
      allow(Net::HTTP).to receive(:get_response).and_return(nil)
      service = SunsetSunriseService.new(valid_params)
      result = service.fetch_sun_day

      expect(result).to have_key(:error)
      expect(result[:error]).to match(/API request failed/)
    end
  end

  context 'when an exception occurs during DB save' do
    it 'returns an error message' do
      allow(SunHistory).to receive(:create!).and_raise(StandardError.new("DB error"))
      service = SunsetSunriseService.new(valid_params)
      result = service.fetch_sun_day

      expect(result).to have_key(:error)
      expect(result[:error]).to eq('DB error')
    end
  end
end
